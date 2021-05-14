require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Vagrant < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        if node_info['ostype'] =~ /^centos/
          base_config['box'] = node_info['ostype'].sub(/(\d)/, '/\1')
        elsif node_info['ostype'] =~ /^fedora/
          base_config['box'] = node_info['ostype'].sub(/(\d)/, '/\1') + '-cloud-base'
        else
          base_config['box'] = "generic/#{node_info['ostype']}"
        end

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        return base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end
    end
  end
end
