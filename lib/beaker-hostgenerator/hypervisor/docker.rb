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
        base_config['image'].sub!(/(\w+)/, '\1/leap') if node_info['ostype'] =~ /^opensuse/
        base_config['image'].sub!(/(\d{2})/, '\1.') if node_info['ostype'] =~ /^ubuntu/
        if node_info['bits'] == '64'
          base_config['image'] = "amd64/#{base_config['image']}"
        end

        return base_generate_node(node_info, base_config, bhg_version, :docker)
      end
    end
  end
end
