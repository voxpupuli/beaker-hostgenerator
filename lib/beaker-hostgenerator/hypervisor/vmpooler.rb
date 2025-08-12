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
        when /^(debian|ubuntu|vro)/
          os = Regexp.last_match(1)
          arch = case node_info['bits']
                 when '64'
                   'x86_64'
                 when '32'
                   'i386'
                 end

          base_config['template'] ||= "#{node_info['ostype'].sub(os, "#{os}-")}-#{arch}" if arch
        when /^osx(\d+)/
          version = Regexp.last_match(1)
          arch = case node_info['bits']
                 when '64'
                   'x86_64'
                 when 'ARM64'
                   'arm64'
                 end
          name = version.start_with?('10') ? 'osx' : 'macos'
          # Weird exception, but ok
          version = '112' if version == '11' && arch == 'x86_64'

          base_config['template'] ||= "#{name}-#{version}-#{arch}"
        when /^solaris(\d+)/
          version = Regexp.last_match(1)
          # for some reason 32 bits is also using x86_64
          arch = case node_info['bits']
                 when '64', '32'
                   'x86_64'
                 end

          base_config['template'] ||= "solaris-#{version}-#{arch}" if arch
        end

        base_config
      end
    end
  end
end
