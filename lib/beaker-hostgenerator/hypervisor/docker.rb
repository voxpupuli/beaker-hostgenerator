require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge'

module BeakerHostGenerator
  module Hypervisor
    class Docker < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        base_config['hypervisor'] = 'docker'
        base_config['docker_cmd'] = ['/sbin/init']
        base_config['image'] = node_info['ostype'].sub(/(\d)/, ':\1')
        base_config['image'].sub!(/(\d{2})/, '\1.') if node_info['ostype'] =~ /^ubuntu/

        platform = node_info['platform']
        platform_info = get_platform_info(bhg_version, platform, :docker)
        base_config.deep_merge! platform_info

        return base_config
      end
    end
  end
end
