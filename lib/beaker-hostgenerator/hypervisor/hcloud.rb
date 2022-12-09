require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'

module BeakerHostGenerator
  module Hypervisor

    class Hcloud < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        # split ostype into string and array
        # ostype is ubuntu2204, debian10, rocky9
        os, version = node_info['ostype'].split(/(\D+)/).reject!(&:empty?)
        base_config['image'] = case os
        when 'ubuntu'
          "#{os}-#{version[0, 2]}.#{version[2,2]}"
        when 'centos'
          version.to_i == 7 ? "#{os}-#{version}" : "#{os}-stream-#{version}"
        else
          "#{os}-#{version}"
        end
        return base_generate_node(node_info, base_config, bhg_version, :hcloud)
      end
    end
  end
end
