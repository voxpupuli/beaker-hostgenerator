require 'beaker-hostgenerator/generator'
require 'beaker-hostgenerator/data/vmpooler'
require 'beaker-hostgenerator/data'
require 'deep_merge'

module BeakerHostGenerator
      class Vmpooler < BeakerHostGenerator::Generator
        include BeakerHostGenerator::Data
        include BeakerHostGenerator::Data::Vmpooler

        def initialize(options)
          @config = {}
          @config.deep_merge! BASE_CONFIG
          @config.deep_merge! VMPOOLER_CONFIG
          super(options)
        end

        def generate_node node_info, base_config
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

          host_config.deep_merge! OSINFO[platform]

          # Some vmpooler/vsphere platforms have special requirements. We munge the
          # node host_config here if that is necessary.
          fixup_node host_config

          return name, host_config
        end

        def is_ostype_token? token
           OSINFO.each do |key,value|

             ostype = key.split('-')[0]

             if ostype == token
               return true
             end

           end

           return false
        end

      end
end
