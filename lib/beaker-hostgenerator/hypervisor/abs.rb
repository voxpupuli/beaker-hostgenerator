require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge'

module BeakerHostGenerator
  module Hypervisor
    class ABS < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        base_config['hypervisor'] = 'abs'

        # For now, we just reuse the vmpooler data
        platform = node_info['platform']
        platform_info = get_platform_info(bhg_version, platform, :vmpooler)

        base_config.deep_merge! platform_info

        return base_config
      end
    end
  end
end
