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
        when /^ubuntu(?<year>\d{2}+)(?<month>\d{2})$/
          # use ubuntu-lts for LTS releases
          "template:ubuntu-#{Regexp.last_match(:year)}.#{Regexp.last_match(:month)}"
        when /^centos(\d+)$/
          version = Regexp.last_match(1)
          name = (version.to_i == 7) ? 'centos' : 'centos-stream'
          "template:#{name}-#{version}"
        when /^oracle(\d+)$/
          version = Regexp.last_match(1)
          "template:oraclelinux-#{version}"
        when /^opensuse(\d+)$/
          version = Regexp.last_match(1)
          "template:opensuse-leap-#{version}"
        when /^(?<name>[a-z]+)(?<version>\d+)$/
          name = Regexp.last_match(:name)
          version = Regexp.last_match(:version)
          "template:#{name}-#{version}"
        else
          "template:#{ostype}"
        end
      end
    end
  end
end
