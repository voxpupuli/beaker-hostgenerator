module BeakerHostGenerator
  module Hypervisor
    # Factory method to instantiate the appropriate hypervisor for the given node.
    def self.create(node_info, options)
      hypervisor = options[:hypervisor] || 'vmpooler'
      case hypervisor
      when 'vmpooler'
        BeakerHostGenerator::Hypervisor::Vmpooler.new
      else
        raise "Invalid hypervisor #{hypervisor}"
      end
    end

    class Interface
      def global_config()
        raise "Method 'global_config' not implemented!"
      end

      def generate_node(node_info, base_config, bhg_version)
        raise "Method 'generate_node' not implemented!"
      end
    end
  end
end

require 'beaker-hostgenerator/hypervisor/vmpooler'
