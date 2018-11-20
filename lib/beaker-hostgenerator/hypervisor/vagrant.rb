require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge'

module BeakerHostGenerator
  module Hypervisor
    class Vagrant < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        base_config['hypervisor'] = 'vagrant'

        if node_info['ostype'] =~ /^centos/
          base_config['box'] = node_info['ostype'].sub(/(\d)/, '/\1')
        elsif node_info['ostype'] =~ /^fedora/
          base_config['box'] = node_info['ostype'].sub(/(\d)/, '/\1') + 'cloud-base'
        else
          base_config['box'] = "generic/#{node_info['ostype']}"
        end

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        platform = node_info['platform']
        platform_info = get_platform_info(bhg_version, platform, :vagrant)
        base_config.deep_merge! platform_info

        return base_config
      end
    end
  end
end
