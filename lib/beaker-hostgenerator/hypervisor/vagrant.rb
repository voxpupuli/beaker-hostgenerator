require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Vagrant < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      DEBIAN_VERSION_CODES = {
        # No newer releases available
        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1104105
        '13' => 'trixie',
        '12' => 'bookworm',
        '11' => 'bullseye',
        '10' => 'buster',
      }.freeze

      def generate_node(node_info, base_config, bhg_version)
        base_config['box'] = case node_info['ostype']
                             when /^almalinux/
                               node_info['ostype'].sub(/(\d)/, '/\1')
                             when /^fedora/
                               node_info['ostype'].sub(/(\d)/, '/\1') + '-cloud-base'
                             else
                               "generic/#{node_info['ostype']}"
                             end

        case node_info['platform']
        when /^debian(\d+)-64/
          version = Regexp.last_match(1)
          if (codename = DEBIAN_VERSION_CODES[version])
            base_config['box'] = "debian/#{codename}64"
          end
        when /^centos(\d+)-64/
          version = Regexp.last_match(1)
          ver = version.to_i
          if ver >= 8
            provider, extension = (@name == 'vagrant_libvirt') ? %w[Libvirt vagrant-libvirt] : %w[VirtualBox vagrant-virtualbox]
            variant = (ver == 8) ? 'Vagrant' : "Vagrant-#{provider}"
            base_config['box_url'] = "https://cloud.centos.org/centos/#{version}-stream/x86_64/images/CentOS-Stream-#{variant}-#{version}-latest.x86_64.#{extension}.box"
          else
            base_config['box'] = "centos/#{version}"
          end
        end

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end
    end
  end
end
