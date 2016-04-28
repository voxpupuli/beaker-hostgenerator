module BeakerHostGenerator

  # Defines an Interface for the implementation of a hypervisor, and provides
  # a static module function `create(node_info, options)` for instantiating
  # the appropriate hypervisor implementation.
  #
  # New hypervisor implementations must define the methods in the Interface
  # class, and add a new case branch to the `create` factory method.
  #
  # Any number of hypervisors are used by a single Generator during host
  # generation in the `BeakerHostGenerator::Generator#generate` method.
  # Whenever a host specifies a specific hypervisor implementation, the
  # Generator will instantiate the appropriate hypervisor via
  # `BeakerHostGenerator::Hypervisor.create`.
  module Hypervisor

    # Static factory method to instantiate the appropriate hypervisor for the
    # given node. If no hypervisor is specified in the node info, then the
    # hypervisor specified in the options will be created.
    #
    # @param node_info [Hash{String=>Object}] Node data parsed from the input
    #                                         spec string.
    #
    # @option options [String] :hypervisor The string name of the hypervisor to
    #                          create. An exception will be thrown if the
    #                          hypervisor is unrecognized.
    def self.create(node_info, options)
      hypervisor =
        node_info['host_settings']['hypervisor'] || options[:hypervisor]
      case hypervisor
      when 'vmpooler'
        BeakerHostGenerator::Hypervisor::Vmpooler.new
      when 'none'
        BeakerHostGenerator::Hypervisor::None.new
      else
        raise "Invalid hypervisor #{hypervisor}"
      end
    end

    class Interface
      # Returns a map containing any general configuration required by this
      # hypervisor. This map will be merged into the 'CONFIG' section of the
      # final hosts configuration output.
      #
      # This will only be called if the hypervisor is used for a node, in which
      # case the returned map will be merged in with global configuration from
      # other hypervisors.
      def global_config()
        {}
      end

      # Returns a map of host configuration for a single node.
      #
      # This will be called for each individual node requested in the hosts
      # specification input.
      #
      # Any configuration that is required by this hypervisor but is not
      # specific to each node can be put in the `global_config` map.
      #
      # @param [Hash{String=>String}] node_info General info about the given
      #                               node, such as the ostype, nodeid, and
      #                               bits.
      #
      # @param [Hash{String=>Object}] base_config The node definition so far,
      #                               which serves a starting point for this
      #                               hypervisor to build upon. It is expected
      #                               that this map will be merged into the map
      #                               returned by this method.
      #
      # @param [Integer] bhg_version The version of OS info to use when building
      #                              up the node definition.
      def generate_node(node_info, base_config, bhg_version)
        raise "Method 'generate_node' not implemented!"
      end
    end
  end
end

# Require the hypervisor implementations so they can be referenced/instantiated
# in the `create` factory method. We need to put these require statements at the
# bottom of this file to avoid circular references between this file and the
# hypervisor implementation files.
require 'beaker-hostgenerator/hypervisor/vmpooler'
require 'beaker-hostgenerator/hypervisor/none'
