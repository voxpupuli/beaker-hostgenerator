require 'beaker-hostgenerator/hypervisor'
require 'beaker-hostgenerator/data'
require 'deep_merge'

module BeakerHostGenerator::Hypervisor
  class Unknown < BeakerHostGenerator::Hypervisor::Interface
    include BeakerHostGenerator::Data

    def initialize(name)
      @name = name
    end

    def generate_node(node_info, base_config, bhg_version)
      platform = node_info['platform']
      general_info = get_platform_info(bhg_version, platform, :general)
      base_config.deep_merge! general_info
      base_config['hypervisor'] = @name
      return base_config
    end
  end
end
