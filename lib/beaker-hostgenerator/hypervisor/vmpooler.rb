require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge'

module BeakerHostGenerator
  module Hypervisor
    class Vmpooler < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      # default global configuration keys
      def global_config()
        {
          'pooling_api' => 'http://vmpooler.delivery.puppetlabs.net/'
        }
      end

      def generate_node(node_info, base_config, bhg_version)
        # set hypervisor
        base_config['hypervisor'] = 'vmpooler'

        platform = node_info['platform']
        platform_info = get_platform_info(bhg_version, platform, :vmpooler)
        base_config.deep_merge! platform_info

        # Some vmpooler/vsphere platforms have special requirements.
        # We munge the node host config here if that is necessary.
        fixup_node base_config

        return base_config
      end
    end
  end
end
