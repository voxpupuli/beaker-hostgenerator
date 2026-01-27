require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Vagrant < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      DEBIAN_VERSION_CODES = {
        # No newer releases available
        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1104105
        '12' => 'bookworm',
        '11' => 'bullseye',
        '10' => 'buster',
      }.freeze

      # Map ostype OS names to their bento box equivalents
      OSTYPE_TO_BENTO_OS_NAME = {
        'rocky' => 'rockylinux',
        'oracle' => 'oraclelinux',
        'redhat' => 'rhel',
        'amazon' => 'amazonlinux',
        'osx' => 'macos',
        'opensuse' => 'opensuse-leap',
      }.freeze

      # Transforms an ostype to a vagrant box name
      def ostype_to_box(ostype)
        case ostype
        when /^almalinux(\d+)/
          ostype.sub(/(\d)/, '/\1')
        when /^centos(\d+)/
          version = Regexp.last_match(1)
          if version.to_i >= 8
            "centos/stream#{version}"
          else
            "centos/#{version}"
          end
        when /^debian(\d+)/
          version = Regexp.last_match(1)
          if (codename = DEBIAN_VERSION_CODES[version])
            "debian/#{codename}64"
          else
            nil
          end
        when /^fedora/
          ostype.sub(/(\d)/, '/\1') + '-cloud-base'
        when /ubuntu(\d\d)(\d\d)/
          version = "#{Regexp.last_match(1)}.#{Regexp.last_match(2)}"
          "bento/ubuntu-#{version}"
        when /^([a-z]+)(\d+)$/
          os_name = Regexp.last_match(1)
          version = Regexp.last_match(2)

          bento_os_name = OSTYPE_TO_BENTO_OS_NAME.fetch(os_name, os_name)

          "bento/#{bento_os_name}-#{version}"
        else
          # Fallback to generic if pattern doesn't match
          "generic/#{ostype}"
        end
      end

      def generate_node(node_info, base_config, bhg_version)
        ostype = node_info['ostype']

        base_config['box'] = ostype_to_box(ostype)

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end
    end
  end
end
