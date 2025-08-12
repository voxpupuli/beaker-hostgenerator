require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    # AlwaysBeScheduling implementation to support CI.next.
    #
    # The ABS services requires the vmpooler template values as input to
    # determine the type of platform that's being requested.
    #
    # Therefore, this hypervisor just reuses the vmpooler hypervisor template
    # values, in addition to ABS-only values for hardware platforms.
    class ABS < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      def generate_node(node_info, base_config, bhg_version)
        # Grab vmpooler data for this platform and any hardware (ABS) data.
        # The assumption here is that these are mutually exclusive; that is,
        # any given platform will have *either* :vmpooler data or :abs data
        # so we're not worried about one overriding the other when we merge
        # the hashes together.
        base_config = base_generate_node(node_info, base_config, bhg_version, :vmpooler, :abs)

        case node_info['ostype']
        when /^(almalinux|centos|oracle|redhat|rocky|scientific)/
          base_config['template'] ||= base_config['platform']&.gsub(/^el/, ::Regexp.last_match(1))
        when /^aix/, /^fedora/, /^opensuse/, /^panos/
          base_config['template'] ||= base_config['platform']
        when /^(debian|ubuntu|amazon(fips)?)/
          os = Regexp.last_match(1)
          base_template = node_info['ostype'].sub(os, "#{os}-")
          arch = case node_info['bits']
                 when '64'
                   'x86_64'
                 when '32'
                   'i386'
                 when 'AARCH64'
                   'arm64'
                 when 'POWER'
                   base_template.sub!(/#{os}-(\d\d)/, "#{os}-\1.")
                   'power8'
                 else
                   raise "Unknown bits '#{node_info['bits']}' for '#{node_info['ostype']}'"
                 end
          base_config['template'] ||= "#{base_template}-#{arch}"
        when /^osx/
          base_config['template'] ||= base_config['platform']&.gsub(/^osx/, 'macos')
        when /^solaris(\d+)/
          version = Regexp.last_match(1)
          arch = (node_info['bits'] == 'SPARC') ? 'sparc' : nil

          base_config['template'] ||= "solaris-#{version}-#{arch}" if arch
        end

        base_config
      end
    end
  end
end
