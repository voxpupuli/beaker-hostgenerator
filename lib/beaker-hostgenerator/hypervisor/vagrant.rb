require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Vagrant < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        base_config['box'] = if node_info['ostype'] =~ /^centos/
                               node_info['ostype'].sub(/(\d)/, '/\1')
                             elsif node_info['ostype'] =~ /^fedora/
                               node_info['ostype'].sub(/(\d)/, '/\1') + '-cloud-base'
                             else
                               "generic/#{node_info['ostype']}"
                             end

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end
    end
  end
end
