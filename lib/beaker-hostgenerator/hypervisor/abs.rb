require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge'

module BeakerHostGenerator
  module Hypervisor
    # AlwaysBeScheduling implementation to support CI.next.
    #
    # The ABS services requires the vmpooler template values as input to
    # determine the type of platform that's being requested.
    #
    # Therefore, this hypervisor just reuses the vmpooler hypervisor template
    # values, and in the future will likely contain the fake template values to
    # use for non-vmpooler platforms like AIX.
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
