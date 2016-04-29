require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge'

module BeakerHostGenerator
  module Hypervisor
    class Vmpooler < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def global_config()
        {
          'pooling_api' => 'http://vmpooler.delivery.puppetlabs.net/'
        }
      end

      def generate_node(node_info, base_config, bhg_version)
        host_config = {}
        host_config.deep_merge! base_config

        # set hypervisor
        host_config['hypervisor'] = 'vmpooler'

        # generate node definition
        ostype = node_info['ostype']
        nodeid = node_info['nodeid']
        bits = node_info['bits']

        platform = "#{ostype}-#{bits}"
        name = "#{platform}-#{nodeid}"

        platform_info = get_platform_info(bhg_version, platform, :vmpooler)
        host_config.deep_merge! platform_info

        # Some vmpooler/vsphere platforms have special requirements. We munge the
        # node host_config here if that is necessary.
        fixup_node host_config

        return name, host_config
      end
    end
  end
end
