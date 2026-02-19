require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'

module BeakerHostGenerator
  module Hypervisor
    # Implementation of the Lima hypervisor interface to generate host configurations
    # for nodes that use Lima as their hypervisor.
    class Lima < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        # Generate the Lima template URL based on the OS type
        template = get_template(node_info['ostype'])
        arch =  case node_info['bits']
                when '64'
                  'x86_64'
                when 'AARCH64'
                  'aarch64'
                end

        base_config['lima'] = {
          'config' => {
            'arch' => arch,
            'vmType' => 'qemu',
            'base' => [template],
          },
        }

        base_generate_node(node_info, base_config, bhg_version, :lima)
      end

      private

      def get_template(ostype)
        case ostype
        # Ubuntu - use ubuntu-lts for LTS releases
        when /^ubuntu(\d+)$/
          version = Regexp.last_match(1)
          "template:ubuntu-#{version[0, 2]}.#{version[2, 2]}"

        # Debian
        when /^debian(\d+)$/
          version = Regexp.last_match(1)
          "template:debian-#{version}"

        # CentOS and variants
        when /^centos(\d+)$/
          version = Regexp.last_match(1)
          (version.to_i == 7) ? "template:centos-#{version}" : "template:centos-stream-#{version}"

        # AlmaLinux
        when /^almalinux(\d+)$/
          version = Regexp.last_match(1)
          "template:almalinux-#{version}"

        # Rocky Linux
        when /^rocky(\d+)$/
          version = Regexp.last_match(1)
          "template:rocky-#{version}"

        # Oracle Linux
        when /^oracle(\d+)$/
          version = Regexp.last_match(1)
          "template:oraclelinux-#{version}"

        # Fedora
        when /^fedora(\d+)$/
          version = Regexp.last_match(1)
          "template:fedora-#{version}"

        # OpenSUSE
        when /^opensuse(\d+)$/
          version = Regexp.last_match(1)
          "template:opensuse-leap-#{version}"

        # Default fallback - use ostype as-is
        else
          "template:#{ostype}"
        end
      end
    end
  end
end
