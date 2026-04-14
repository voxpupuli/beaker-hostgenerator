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

      ROCKY_LINUX_BOXES = {
        # there is no generic/rocky10, so we introduce this workaround
        # bento/ does not support libvirt
        '10' => 'cloud-image/rocky-10',
        '9' => 'generic/rocky9',
        '8' => 'generic/rocky8',
      }.freeze

      ORACLE_LINUX_BOXES = {
        '10' => 'cloud-image/rocky-10', # We know this is wrong, but there is no Oracle-10
        '9' => 'generic/oracle9',
        '8' => 'generic/oracle8',
      }.freeze

      def generate_node(node_info, base_config, bhg_version)
        base_config['box'] = case node_info['ostype']
                             when /^almalinux/
                               node_info['ostype'].sub(/(\d)/, '/\1')
                             when /^fedora/
                               node_info['ostype'].sub(/(\d)/, '/\1') + '-cloud-base'
                             when /^rocky/
                               majorversion = node_info['ostype'].match(/\d+/)[0]
                               ROCKY_LINUX_BOXES[majorversion]
                             when /^oracle/
                               majorversion = node_info['ostype'].match(/\d+/)[0]
                               ORACLE_LINUX_BOXES[majorversion]
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
          base_config['box'] = (version.to_i >= 8) ? "centos/stream#{version}" : "centos/#{version}"
        end

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end
    end
  end
end
