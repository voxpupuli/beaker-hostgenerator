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
      #
      # The cloud-image/ boxes here and in PLATFORM_BOX_OVERRIDES are temporary.
      # They are hosted on Vagrant Cloud (HCP Vagrant), which shuts down on
      # 31 December 2026, after which they no longer resolve. Each of them needs
      # a box_url pointing at a host that keeps serving it, which is to be added
      # in a follow-up. Until then, the nightly smoke test from #500 is what
      # notices a box that has stopped resolving.
      BOX_OVERRIDES = {
        # Oracle publishes its own boxes (including libvirt) in a catalog rather
        # than on Vagrant Cloud, so the box needs to be fetched from there.
        # https://yum.oracle.com/boxes/
        'oracle7' => {
          'box' => 'oraclelinux/7',
          'box_url' => 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/7.json',
        },
        'oracle8' => {
          'box' => 'oraclelinux/8',
          'box_url' => 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/8.json',
        },
        'oracle9' => {
          'box' => 'oraclelinux/9',
          'box_url' => 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/9.json',
        },
        'oracle10' => {
          'box' => 'oraclelinux/10',
          'box_url' => 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/10.json',
        },
        # The generic/ubuntu2204 box has DNS issues.
        'ubuntu2204' => {
          'box' => 'cloud-image/ubuntu-22.04',
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
        # These Oracle catalogs are for x86_64 only. The aarch64 boxes
        # are in PROVIDER_PLATFORM_BOX_OVERRIDES, which is checked first.
        'oracle7' => %w[64].freeze,
        'oracle8' => %w[64].freeze,
        'oracle9' => %w[64].freeze,
        'oracle10' => %w[64].freeze,
      }.freeze

      # Platforms whose box depends on the hypervisor, by platform and then by
      # hypervisor name. A hypervisor that is not listed for the platform has no
      # box, and raises an error. These take precedence over
      # PLATFORM_BOX_OVERRIDES and BOX_OVERRIDES.
      #
      # Oracle publishes aarch64 boxes in a catalog of their own, for
      # VirtualBox only (the "Apple Silicon" boxes). The libvirt boxes are
      # x86_64 only. https://yum.oracle.com/boxes/
      PROVIDER_PLATFORM_BOX_OVERRIDES = {
        'ubuntu2204-64' => {
          'vagrant' => {
            'box' => 'ubuntu-jammy-amd64',
            'box_url' => 'https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64-vagrant.box',
          },
          'vagrant_libvirt' => BOX_OVERRIDES.fetch('ubuntu2204'),
        },
        'oracle8-AARCH64' => {
          'vagrant' => {
            'box' => 'oraclelinux/8-aarch64',
            'box_url' => 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/8-aarch64.json',
          },
        },
        'oracle9-AARCH64' => {
          'vagrant' => {
            'box' => 'oraclelinux/9-aarch64',
            'box_url' => 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/9-aarch64.json',
          },
        },
        'oracle10-AARCH64' => {
          'vagrant' => {
            'box' => 'oraclelinux/10-aarch64',
            'box_url' => 'https://oracle.github.io/vagrant-projects/boxes/oraclelinux/10-aarch64.json',
          },
        },
      }.freeze

      # Platforms (OS and architecture) whose default box has no build for that
      # architecture, while the same OS on another architecture is fine.
      # These take precedence over BOX_OVERRIDES. The cloud-image/ boxes are
      # temporary, as explained at BOX_OVERRIDES.
      PLATFORM_BOX_OVERRIDES = {
        # The debian/ boxes are only mapped for 64 bit, so ARM64 would fall
        # back to generic/debian13 (see BOX_OVERRIDES for generic/).
        'debian13-AARCH64' => {
          'box' => 'cloud-image/debian-13',
        },
      }.freeze

      # The Vagrant provider used by each hypervisor, for the distributions that
      # publish one box file per provider on their own mirror (CentOS Stream and
      # Rocky Linux). 'provider' is the provider's name, which the file names
      # end in; 'centos_label' and 'rocky_label' are how each distribution
      # spells it in the rest of the file name. Both distributions look the
      # hypervisor up here, so they cannot disagree on which provider it is.
      MIRROR_BOX_PROVIDERS = {
        'vagrant' => {
          'provider' => 'virtualbox',
          'centos_label' => 'VirtualBox',
          'rocky_label' => 'Vbox',
        },
        'vagrant_libvirt' => {
          'provider' => 'libvirt',
          'centos_label' => 'Libvirt',
          'rocky_label' => 'Libvirt',
        },
      }.freeze

      # Rocky Linux releases whose boxes are fetched from Rocky's own mirror
      # rather than Vagrant Cloud (HCP Vagrant), which ends operations on
      # 31 December 2026. https://dl.rockylinux.org/pub/rocky/<version>/images/
      ROCKY_BOX_VERSIONS = %w[9 10].freeze

      # Architecture in box file names, by beaker-hostgenerator bits.
      BOX_FILE_ARCHITECTURES = {
        '64' => 'x86_64',
        'AARCH64' => 'aarch64',
      }.freeze

      def generate_node(node_info, base_config, bhg_version)
        base_config['box'] = case node_info['ostype']
                             when /^openbsd/
                               box = node_info['host_settings']['box']
                               unless box.is_a?(String) && !box.strip.empty?
                                 raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                                       "No default Vagrant box for #{node_info['platform']} with #{@name}. " \
                                       'Specify a provider-compatible box with {box=...}.'
                               end
                               box
                             when /^almalinux/
                               node_info['ostype'].sub(/(\d)/, '/\1')
                             when /^fedora/
                               node_info['ostype'].sub(/(\d)/, '/\1') + '-cloud-base'
                             else
                               "generic/#{node_info['ostype']}"
                             end

        case node_info['platform']
        when /\Aalmalinux(8|9|10)-(?:64|AARCH64)\z/
          # The vendor catalog has ARM64 boxes for VirtualBox. The libvirt
          # fallback is hosted on HCP Vagrant until 31 December 2026.
          if node_info['bits'] == 'AARCH64' && @name == 'vagrant_libvirt'
            base_config['box'] = "cloud-image/almalinux-#{Regexp.last_match(1)}"
          elsif !node_info['host_settings'].key?('box')
            base_config['box_url'] = "https://vagrant.almalinux.org/#{base_config['box']}"
          end
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
        return unless version.to_i >= 8

        provider = MIRROR_BOX_PROVIDERS.fetch(@name)
        # The Stream 8 file has no provider in its name
        variant = (version.to_i == 8) ? 'Vagrant' : "Vagrant-#{provider['centos_label']}"
        "https://cloud.centos.org/centos/#{version}-stream/x86_64/images/" \
          "CentOS-Stream-#{variant}-#{version}-latest.x86_64.vagrant-#{provider['provider']}.box"
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
        unless arch
          raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                "No Vagrant box is available for #{node_info['platform']}. " \
                "Supported architectures: #{BOX_FILE_ARCHITECTURES.keys.join(', ')}. " \
                'Choose a box with {box=...} to use another architecture.'
        end

        # Not a user error if the hypervisor is missing: fail loudly (KeyError)
        # instead of reporting it as an unsupported architecture.
        provider = MIRROR_BOX_PROVIDERS.fetch(@name)

        file = "Rocky-#{version}-Vagrant-#{provider['rocky_label']}.latest.#{arch}.vagrant.#{provider['provider']}.box"
        base_config['box'] = "rockylinux-#{version}-#{arch}"
        base_config['box_url'] = "https://dl.rockylinux.org/pub/rocky/#{version}/images/#{arch}/#{file}"
      end

      # Replaces the default box with the PROVIDER_PLATFORM_BOX_OVERRIDES,
      # PLATFORM_BOX_OVERRIDES or BOX_OVERRIDES entry for the platform, if there
      # is one.
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

        provider_overrides = PROVIDER_PLATFORM_BOX_OVERRIDES[node_info['platform']]
        if provider_overrides
          provider_override = provider_overrides[@name]
          unless provider_override
            raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                  "No Vagrant box is available for #{node_info['platform']} with the #{@name} hypervisor. " \
                  "Supported hypervisors: #{provider_overrides.keys.join(', ')}. " \
                  'Choose a box with {box=...} to use another hypervisor.'
          end

          base_config.merge!(provider_override)
          return
        end

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
