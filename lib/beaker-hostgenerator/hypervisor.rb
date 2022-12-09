module BeakerHostGenerator

  # Defines an Interface for the implementation of a hypervisor, and provides
  # a static module function `create(node_info, options)` for instantiating
  # the appropriate hypervisor implementation.
  #
  # New hypervisor implementations must define the methods in the Interface
  # class, and add a new element to the `builtin_hypervisors` map.
  #
  # Any number of hypervisors are used by a single Generator during host
  # generation in the `BeakerHostGenerator::Generator#generate` method.
  # Whenever a host specifies a specific hypervisor implementation, the
  # Generator will instantiate the appropriate hypervisor via
  # `BeakerHostGenerator::Hypervisor.create`.
  module Hypervisor

    # Static factory method to instantiate the appropriate hypervisor for the
    # given node. If no hypervisor is specified in the node info, then the
    # hypervisor specified in the options will be created. If the hypervisor is
    # not a built-in implementation, then an `Unknown` instance will be used.
    #
    # @param node_info [Hash{String=>Object}] Node data parsed from the input
    #                                         spec string.
    #
    # @option options [String] :hypervisor The string name of the hypervisor to
    #                          create.
    def self.create(node_info, options)
      name = node_info['host_settings']['hypervisor'] || options[:hypervisor]
      hypervisor = builtin_hypervisors[name] || BeakerHostGenerator::Hypervisor::Unknown
      hypervisor.new(name)
    end

    # Returns a map of all built-in hypervisor implementations, where the keys
    # are the string names and the values are the implementation classes.
    #
    # The string names are part of the beaker-hostgenerator API as they are
    # used for specifying the default or per-host hypervisor in the layout
    # specification input string.
    #
    # @returns [Hash{String=>Hypervisor::Interface}] A map of hypervisor names
    #                                                and their implementations.
    def self.builtin_hypervisors()
      {
        'vmpooler' => BeakerHostGenerator::Hypervisor::Vmpooler,
        'vagrant' => BeakerHostGenerator::Hypervisor::Vagrant,
        'vagrant_libvirt' => BeakerHostGenerator::Hypervisor::Vagrant,
        'docker' => BeakerHostGenerator::Hypervisor::Docker,
        'abs' => BeakerHostGenerator::Hypervisor::ABS,
        'hcloud' => BeakerHostGenerator::Hypervisor::Hcloud,
      }
    end

    class Interface
      def initialize(name)
        @name = name
      end

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

      private

      def base_generate_node(node_info, base_config, bhg_version, *hypervisors)
        platform = node_info['platform']
        hypervisors.map do |hypervisor|
          base_config.deeper_merge! get_platform_info(bhg_version, platform, hypervisor)
        end

        base_config['hypervisor'] = @name

        return base_config
      end
    end
  end
end

# Require the hypervisor implementations so they can be referenced/instantiated
# in the `create` factory method. We need to put these require statements at the
# bottom of this file to avoid circular references between this file and the
# hypervisor implementation files.
require 'beaker-hostgenerator/hypervisor/unknown'
require 'beaker-hostgenerator/hypervisor/vmpooler'
require 'beaker-hostgenerator/hypervisor/vagrant'
require 'beaker-hostgenerator/hypervisor/docker'
require 'beaker-hostgenerator/hypervisor/abs'
require 'beaker-hostgenerator/hypervisor/hcloud'
