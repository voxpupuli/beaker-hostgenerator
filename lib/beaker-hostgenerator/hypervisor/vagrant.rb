require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/exceptions'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Vagrant < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      DEBIAN_VERSION_CODES = {
        # No newer releases available
        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1104105
        '13' => 'trixie',
        '12' => 'bookworm',
        '11' => 'bullseye',
        '10' => 'buster',
      }.freeze

      # Platforms where the generic/ namespace has no image. Those boxes were
      # built by Lavabit, which has ceased operations, so no new images are
      # published there. Any platform not listed here falls back to generic/.
      BOX_OVERRIDES = {
        'rocky10' => {
          'box' => 'cloud-image/rocky-10',
        },
        # Oracle publishes its own boxes (including libvirt) in a catalog rather
        # than on Vagrant Cloud, so the box needs to be fetched from there.
        # https://yum.oracle.com/boxes/
        'oracle10' => {
          'box' => 'oraclelinux/10',
          'box_url' => 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/10.json',
        },
        'ubuntu2404' => {
          'box' => 'cloud-image/ubuntu-24.04',
        },
        'ubuntu2604' => {
          'box' => 'cloud-image/ubuntu-26.04',
        },
        'amazon2023' => {
          'box' => 'cloud-image/amazon-linux-2023',
        },
        # Replace the official fedora/<version>-cloud-base box, which is not
        # available for these releases.
        'fedora42' => {
          'box' => 'cloud-image/fedora-42',
        },
        'fedora43' => {
          'box' => 'cloud-image/fedora-43',
        },
      }.freeze

      # Architectures the BOX_OVERRIDES boxes are known to be published for.
      # The box architecture is not part of the generated config: Vagrant
      # detects it from the host. Offering these boxes for any other
      # architecture (POWER, S390X, ...) would hand out a box that does not
      # match the platform, so those are rejected instead.
      BOX_OVERRIDE_BITS = %w[64 AARCH64].freeze

      # Platforms (OS and architecture) whose default box has no build for that
      # architecture, while the same OS on another architecture is fine.
      # These take precedence over BOX_OVERRIDES.
      PLATFORM_BOX_OVERRIDES = {
        # The debian/ boxes are only mapped for 64 bit, so ARM64 would fall
        # back to generic/debian13 (see BOX_OVERRIDES for generic/).
        'debian13-AARCH64' => {
          'box' => 'cloud-image/debian-13',
        },
        # The official almalinux/10 box has no aarch64 build for libvirt or
        # VirtualBox. https://wiki.almalinux.org/installation/vagrant-boxes
        'almalinux10-AARCH64' => {
          'box' => 'cloud-image/almalinux-10',
        },
      }.freeze

      def generate_node(node_info, base_config, bhg_version)
        base_config['box'] = case node_info['ostype']
                             when /^almalinux/
                               node_info['ostype'].sub(/(\d)/, '/\1')
                             when /^fedora/
                               node_info['ostype'].sub(/(\d)/, '/\1') + '-cloud-base'
                             else
                               "generic/#{node_info['ostype']}"
                             end

        case node_info['platform']
        when /^debian(\d+)-64/
          version = Regexp.last_match(1)
          if (codename = DEBIAN_VERSION_CODES[version])
            base_config['box'] = "debian/#{codename}64"
          end
        when /^centos(\d+)-64/
          version = Regexp.last_match(1)
          base_config['box'] = (version.to_i >= 8) ? "centos/stream#{version}" : "centos/#{version}"
        end

        apply_box_override(node_info, base_config)

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end

      private

      # Replaces the default box with the PLATFORM_BOX_OVERRIDES or
      # BOX_OVERRIDES entry for the platform, if there is one.
      #
      # The overrides come as a set: Oracle's box is only valid together with
      # the catalog URL it is fetched from. User host settings are merged in
      # after this method, so a custom box replaces only 'box' and would keep
      # a leftover 'box_url', which Vagrant would then resolve the custom box
      # against. When the user picks their own box, skip the whole set (this
      # also lets them use an architecture that has no override). A 'box_url'
      # on its own is kept as given and applies to the overridden box.
      def apply_box_override(node_info, base_config)
        return if node_info['host_settings'].key?('box')

        platform_override = PLATFORM_BOX_OVERRIDES[node_info['platform']]
        if platform_override
          base_config.merge!(platform_override)
          return
        end

        override = BOX_OVERRIDES[node_info['ostype']]
        return unless override

        unless BOX_OVERRIDE_BITS.include?(node_info['bits'])
          raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                "No Vagrant box is available for #{node_info['platform']}. " \
                "Supported architectures: #{BOX_OVERRIDE_BITS.join(', ')}. " \
                'Choose a box with {box=...} to use another architecture.'
        end

        base_config.merge!(override)
      end
    end
  end
end
