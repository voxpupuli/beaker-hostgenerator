require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Vmpooler < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      # default global configuration keys
      def global_config
        {
          'pooling_api' => 'https://vmpooler-prod.k8s.infracore.puppet.net/',
        }
      end

      def generate_node(node_info, base_config, bhg_version)
        base_config = base_generate_node(node_info, base_config, bhg_version, :vmpooler)

        case node_info['ostype']
        when /^(almalinux|centos|oracle|redhat|rocky|scientific)/
          base_config['template'] ||= base_config['platform']&.gsub(/^el/, ::Regexp.last_match(1))
        when /^fedora/, /^opensuse/, /^panos/
          base_config['template'] ||= base_config['platform']
        when /^(debian|ubuntu)/
          os = Regexp.last_match(1)
          arch = case node_info['bits']
                 when '64'
                   'x86_64'
                 when '32'
                   'i386'
                 end

          base_config['template'] ||= "#{node_info['ostype'].sub(os, "#{os}-")}-#{arch}" if arch
        end

        base_config
      end
    end
  end
end
