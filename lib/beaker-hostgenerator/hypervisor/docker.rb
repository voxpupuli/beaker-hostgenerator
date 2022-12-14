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

        docker_commands = []

        case node_info['ostype']
        when /^ubuntu/
          docker_commands << 'cp /bin/true /sbin/agetty'

          if node_info['ostype'] =~ /1404/
            docker_commands << 'rm /usr/sbin/policy-rc.d'
            docker_commands << 'rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl'
          end

          extra_packages_to_install = case node_info['ostype']
                                      when /1404/
                                        ['apt-transport-https']
                                      when /1604/
                                        ['locales']
                                      else
                                        ['locales', 'iproute2', 'gnupg']
                                      end

          docker_commands << "apt-get install -y net-tools wget #{extra_packages_to_install.join(' ')}"
          docker_commands << 'locale-gen en_US.UTF-8'
          docker_commands << 'echo LANG=en_US.UTF-8 > /etc/default/locale'

          base_config['docker_image_commands'] = docker_commands
        end

        return base_generate_node(node_info, base_config, bhg_version, :docker)
      end
    end
  end
end
