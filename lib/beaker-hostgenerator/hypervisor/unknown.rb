require 'beaker-hostgenerator/hypervisor'
require 'beaker-hostgenerator/data'
require 'deep_merge/rails_compat'

module BeakerHostGenerator::Hypervisor
  class Unknown < BeakerHostGenerator::Hypervisor::Interface
    include BeakerHostGenerator::Data

    def generate_node(node_info, base_config, bhg_version)
      return base_generate_node(node_info, base_config, bhg_version, :general)
    end
  end
end
