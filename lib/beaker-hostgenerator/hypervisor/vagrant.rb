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
        '12' => 'bookworm',
        '11' => 'bullseye',
        '10' => 'buster',
      }.freeze

      # Map ostype OS names to their bento box equivalents
      OSTYPE_TO_BENTO_OS_NAME = {
        'rocky' => 'rockylinux',
        'oracle' => 'oraclelinux',
        'redhat' => 'rhel',
        'amazon' => 'amazonlinux',
        'osx' => 'macos',
        'opensuse' => 'opensuse-leap',
      }.freeze

      # Transforms an ostype like "ubuntu2204" to a bento box name like "bento/ubuntu-22.04"
      def ostype_to_bento_box(ostype)
        # Extract the OS name and version from ostype (e.g., "ubuntu2204" -> "ubuntu" and "2204")
        if ostype =~ /^([a-z]+)(\d+)$/
          os_name = Regexp.last_match(1)
          version = Regexp.last_match(2)

          # Map ostype OS name to bento OS name
          bento_os_name = OSTYPE_TO_BENTO_OS_NAME.fetch(os_name, os_name)

          # Format version with dots for Ubuntu's 4-digit versions (e.g., ubuntu2204 -> 22.04)
          # Ubuntu uses YY.MM format like 22.04, 24.04
          formatted_version = if os_name == 'ubuntu' && version.length == 4
                                "#{version[0, 2]}.#{version[2, 2]}"
                              else
                                version
                              end

          "bento/#{bento_os_name}-#{formatted_version}"
        else
          # Fallback to generic if pattern doesn't match
          "generic/#{ostype}"
        end
      end

      def generate_node(node_info, base_config, bhg_version)
        ostype = node_info['ostype']

        base_config['box'] = case ostype
                             when /^almalinux/
                               ostype.sub(/(\d)/, '/\1')
                             when /^fedora/
                               ostype.sub(/(\d)/, '/\1') + '-cloud-base'
                             when /^centos(\d+)/
                               version = Regexp.last_match(1)
                               if version.to_i >= 8
                                 "centos/stream#{version}"
                               else
                                 "centos/#{version}"
                               end
                             else
                               ostype_to_bento_box(ostype)
                             end

        case node_info['platform']
        when /^debian(\d+)-64/
          version = Regexp.last_match(1)
          if (codename = DEBIAN_VERSION_CODES[version])
            base_config['box'] = "debian/#{codename}64"
          end
        when /^centos(\d+)-64/
          version = Regexp.last_match(1)
          if version.to_i >= 8
            base_config['box_url'] = "https://cloud.centos.org/centos/#{version}-stream/x86_64/images/CentOS-Stream-Vagrant-#{version}-latest.x86_64.vagrant-libvirt.box"
          end
        end

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end
    end
  end
end
