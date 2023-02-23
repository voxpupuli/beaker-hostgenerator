require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Docker < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        base_config['docker_cmd'] = ['/sbin/init']
        base_config['image'] = node_info['ostype'].sub(/(\d)/, ':\1')
        case node_info['ostype']
        when /^oracle/
          base_config['image'].sub!(/\w+/, 'oraclelinux')
        when /^opensuse/
          base_config['image'].sub!(/(\w+)/, '\1/leap')
        when /^ubuntu/
          base_config['image'].sub!(/(\d{2})/, '\1.')
        when /^rocky/
          base_config['image'].sub!(/(\w+)/, 'rockylinux')
        when /^alma/
          base_config['image'].sub!(/(\w+)/, 'almalinux')
        end

        if node_info['bits'] == '64'
          base_config['image'] = "amd64/#{base_config['image']}"
        end

        case node_info['ostype']
        when /^ubuntu/
          base_config['docker_image_commands'] = [
            'cp /bin/true /sbin/agetty',
            'apt-get install -y net-tools wget locales iproute2 gnupg',
            'locale-gen en_US.UTF-8',
            'echo LANG=en_US.UTF-8 > /etc/default/locale',
          ]
        end

        base_generate_node(node_info, base_config, bhg_version, :docker)
      end
    end
  end
end
