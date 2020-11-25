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
        # Grab vmpooler data for this platform and any hardware (ABS) data.
        # The assumption here is that these are mutually exclusive; that is,
        # any given platform will have *either* :vmpooler data or :abs data
        # so we're not worried about one overriding the other when we merge
        # the hashes together.
        base_config = base_generate_node(node_info, base_config, bhg_version, :vmpooler, :abs)

        case node_info['ostype']
        when /^centos/
          base_config['template'] = base_config['platform'].gsub(/^el/, 'centos')
        when /^fedora/
          base_config['template'] = base_config['platform']
        end

        base_config
      end
    end
  end
end
