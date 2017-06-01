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
    # values, in addition to ABS-only values for hardware platforms.
    class ABS < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        base_config['hypervisor'] = 'abs'

        # Grab vmpooler data for this platform and any hardware (ABS) data.
        # The assumption here is that these are mutually exclusive; that is,
        # any given platform will have *either* :vmpooler data or :abs data
        # so we're not worried about one overriding the other when we merge
        # the hashes together.
        platform = node_info['platform']
        vmpooler_platform_info = get_platform_info(bhg_version, platform, :vmpooler)
        abs_platform_info = get_platform_info(bhg_version, platform, :abs)

        base_config.deep_merge! vmpooler_platform_info
        base_config.deep_merge! abs_platform_info

        return base_config
      end
    end
  end
end
