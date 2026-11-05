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

      # Platforms whose default box does not exist. For most of them that is the
      # generic/ namespace: those boxes were built by Lavabit, which has ceased
      # operations, so no new images are published there. A platform not listed
      # here keeps its default box (generic/<ostype>, or the OS's own box such
      # as debian/ or centos/).
      BOX_OVERRIDES = {
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
      # detects it from the host. Offering a box for an architecture it has
      # no build for would hand out a box that does not match the platform,
      # so those are rejected instead. Boxes not listed in BOX_OVERRIDE_BITS
      # are taken to have 64 bit and AARCH64 builds.
      DEFAULT_BOX_OVERRIDE_BITS = %w[64 AARCH64].freeze
      BOX_OVERRIDE_BITS = {
        # Oracle's catalog only lists x86_64 boxes.
        'oracle10' => %w[64].freeze,
      }.freeze

      # Platforms (OS and architecture) whose default box has no build for that
      # architecture, while the same OS on another architecture is fine.
      # These take precedence over BOX_OVERRIDES.
      PLATFORM_BOX_OVERRIDES = {
        # The debian/ boxes are only mapped for 64 bit, so ARM64 would fall
        # back to generic/debian13 (see BOX_OVERRIDES for generic/).
        'debian13-AARCH64' => {
          'box' => 'cloud-image/debian-13',
        },
        # The official almalinux/<version> boxes have no aarch64 build for
        # libvirt or VirtualBox. https://wiki.almalinux.org/installation/vagrant-boxes
        'almalinux9-AARCH64' => {
          'box' => 'cloud-image/almalinux-9',
        },
        'almalinux10-AARCH64' => {
          'box' => 'cloud-image/almalinux-10',
        },
      }.freeze

      # Vagrant provider used by each hypervisor, as CentOS spells it in the
      # names of its box files.
      CENTOS_STREAM_PROVIDERS = {
        'vagrant' => 'VirtualBox',
        'vagrant_libvirt' => 'Libvirt',
      }.freeze

      # Rocky Linux releases whose boxes are fetched from Rocky's own mirror
      # rather than Vagrant Cloud (HCP Vagrant), which ends operations on
      # 31 December 2026. https://dl.rockylinux.org/pub/rocky/10/images/
      ROCKY_BOX_VERSIONS = %w[10].freeze

      # Vagrant provider used by each hypervisor, as Rocky spells it in the
      # names of its box files: [label, provider].
      ROCKY_BOX_PROVIDERS = {
        'vagrant' => %w[Vbox virtualbox],
        'vagrant_libvirt' => %w[Libvirt libvirt],
      }.freeze

      # Architecture in box file names, by beaker-hostgenerator bits.
      BOX_FILE_ARCHITECTURES = {
        '64' => 'x86_64',
        'AARCH64' => 'aarch64',
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
          # Like the box overrides below, a box picked by the user replaces this
          box_url = centos_stream_box_url(version)
          base_config['box_url'] = box_url if box_url && !node_info['host_settings'].key?('box')
        when /^rocky(\d+)-/
          version = Regexp.last_match(1)
          apply_rocky_box(node_info, base_config, version) if ROCKY_BOX_VERSIONS.include?(version)
        end

        apply_box_override(node_info, base_config)

        # We don't use this by default
        base_config['synced_folder'] = 'disabled'

        base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end

      private

      # CentOS publishes its Stream boxes on its own mirror, as one plain .box
      # file per provider. The copies on Vagrant Cloud fail to download
      # (HTTP 502), and Vagrant Cloud shuts down at the end of 2026, so fetch
      # the box from the mirror. The 'latest' files are replaced in place on
      # every release.
      def centos_stream_box_url(version)
        provider = CENTOS_STREAM_PROVIDERS[@name]
        return unless provider && version.to_i >= 8

        # The Stream 8 file has no provider in its name
        variant = (version.to_i == 8) ? 'Vagrant' : "Vagrant-#{provider}"
        "https://cloud.centos.org/centos/#{version}-stream/x86_64/images/" \
          "CentOS-Stream-#{variant}-#{version}-latest.x86_64.vagrant-#{provider.downcase}.box"
      end

      # Rocky publishes its boxes on its mirror as one plain .box file per
      # architecture and provider. As with CentOS, the 'latest' files are
      # replaced in place on every release. The architecture is part of the
      # file name, so the box matches the platform whatever the host is. It is
      # part of the local box name too, so that a box of the other
      # architecture already in the Vagrant cache is not used instead.
      def apply_rocky_box(node_info, base_config, version)
        return if node_info['host_settings'].key?('box')

        arch = BOX_FILE_ARCHITECTURES[node_info['bits']]
        label, provider = ROCKY_BOX_PROVIDERS[@name]
        unless arch && label
          raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                "No Vagrant box is available for #{node_info['platform']}. " \
                "Supported architectures: #{BOX_FILE_ARCHITECTURES.keys.join(', ')}. " \
                'Choose a box with {box=...} to use another architecture.'
        end

        base_config['box'] = "rockylinux-#{version}-#{arch}"
        base_config['box_url'] = "https://dl.rockylinux.org/pub/rocky/#{version}/images/#{arch}/" \
                                 "Rocky-#{version}-Vagrant-#{label}.latest.#{arch}.vagrant.#{provider}.box"
      end

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

        supported_bits = BOX_OVERRIDE_BITS.fetch(node_info['ostype'], DEFAULT_BOX_OVERRIDE_BITS)
        unless supported_bits.include?(node_info['bits'])
          raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                "No Vagrant box is available for #{node_info['platform']}. " \
                "Supported architectures: #{supported_bits.join(', ')}. " \
                'Choose a box with {box=...} to use another architecture.'
        end

        base_config.merge!(override)
      end
    end
  end
end
