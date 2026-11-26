require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/exceptions'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Vagrant < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      # Default catalogs shared by both Vagrant providers on x86_64.
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
      }.freeze

      # Provider-specific catalogs and direct box downloads. These take
      # precedence over the shared platform and OS catalogs.
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

      # Catalogs available to both providers on the named platforms.
      PLATFORM_BOX_OVERRIDES = {
        'ubuntu2404-64' => {
          'box' => 'cloudsoe/ubuntu-24.04',
          'box_url' => 'https://boxes.cloudsoe.com/cloudsoe/ubuntu-24.04.json',
        },
        'ubuntu2604-64' => {
          'box' => 'cloudsoe/ubuntu-26.04',
          'box_url' => 'https://boxes.cloudsoe.com/cloudsoe/ubuntu-26.04.json',
        },
        'debian12-64' => {
          'box' => 'cloudsoe/debian-12',
          'box_url' => 'https://boxes.cloudsoe.com/cloudsoe/debian-12.json',
        },
        'debian13-64' => {
          'box' => 'cloudsoe/debian-13',
          'box_url' => 'https://boxes.cloudsoe.com/cloudsoe/debian-13.json',
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
      ROCKY_BOX_VERSIONS = %w[8 9 10].freeze

      # Release compose IDs appearing in Fedora's official box filenames.
      FEDORA_BOX_COMPOSES = { '44' => '1.7', '45' => '1.4' }.freeze

      # Architecture in box file names, by beaker-hostgenerator bits.
      BOX_FILE_ARCHITECTURES = {
        '64' => 'x86_64',
        'AARCH64' => 'aarch64',
      }.freeze

      def generate_node(node_info, base_config, bhg_version)
        settings = node_info['host_settings']
        configure_default_box(node_info, base_config) unless settings.key?('box')

        box = settings.fetch('box') { base_config['box'] }
        unless box.is_a?(String) && !box.strip.empty?
          raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                "No default Vagrant box for #{node_info['platform']} with #{@name}. " \
                'Specify a provider-compatible box with {box=...}.'
        end

        base_config['synced_folder'] = 'disabled'
        base_generate_node(node_info, base_config, bhg_version, :vagrant)
      end

      private

      def configure_default_box(node_info, base_config)
        case node_info['platform']
        when /\Aalmalinux(8|9|10)-(?:64|AARCH64)\z/
          return if node_info['platform'] == 'almalinux8-AARCH64' || (node_info['bits'] == 'AARCH64' && @name == 'vagrant_libvirt')

          base_config['box'] = "almalinux/#{Regexp.last_match(1)}"
          base_config['box_url'] = "https://vagrant.almalinux.org/#{base_config['box']}"
        when /\Acentos(8|9|10)-64\z/
          version = Regexp.last_match(1)
          base_config['box'] = "centos/stream#{version}"
          base_config['box_url'] = centos_stream_box_url(version)
        when /\Afedora(44|45)-(?:64|AARCH64)\z/
          apply_fedora_box(node_info, base_config, Regexp.last_match(1))
        when /\Arocky(\d+)-/
          version = Regexp.last_match(1)
          apply_rocky_box(node_info, base_config, version) if ROCKY_BOX_VERSIONS.include?(version)
        else
          apply_box_override(node_info, base_config)
        end
      end

      # CentOS publishes its Stream boxes on its own mirror, as one plain .box
      # file per provider. The copies on Vagrant Cloud fail to download
      # (HTTP 502), and Vagrant Cloud shuts down at the end of 2026, so fetch
      # the box from the mirror. The 'latest' files are replaced in place on
      # every release.
      def centos_stream_box_url(version)
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
        if version == '8' && @name == 'vagrant_libvirt'
          raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                "No default Vagrant box for #{node_info['platform']} with #{@name}. " \
                'The official Rocky Linux 8 libvirt box fails to boot under BIOS. ' \
                'Specify a provider-compatible box with {box=...}.'
        end

        supported_bits = (version == '8') ? ['64'] : BOX_FILE_ARCHITECTURES.keys
        unless supported_bits.include?(node_info['bits'])
          raise BeakerHostGenerator::Exceptions::InvalidNodeSpecError,
                "No Vagrant box is available for #{node_info['platform']}. " \
                "Supported architectures: #{supported_bits.join(', ')}. " \
                'Choose a box with {box=...} to use another architecture.'
        end

        arch = BOX_FILE_ARCHITECTURES.fetch(node_info['bits'])

        # Not a user error if the hypervisor is missing: fail loudly (KeyError)
        # instead of reporting it as an unsupported architecture.
        provider = MIRROR_BOX_PROVIDERS.fetch(@name)

        # Rocky 8 predates the provider suffix used by Rocky 9 and 10.
        suffix = (version == '8') ? 'box' : "vagrant.#{provider['provider']}.box"
        file = "Rocky-#{version}-Vagrant-#{provider['rocky_label']}.latest.#{arch}.#{suffix}"
        base_config['box'] = "rockylinux-#{version}-#{arch}"
        base_config['box_url'] = "https://dl.rockylinux.org/pub/rocky/#{version}/images/#{arch}/#{file}"
      end

      def apply_fedora_box(node_info, base_config, version)
        arch = BOX_FILE_ARCHITECTURES.fetch(node_info['bits'])
        provider = MIRROR_BOX_PROVIDERS.fetch(@name).fetch('provider')
        return if arch == 'aarch64' && provider == 'virtualbox'

        label = (provider == 'virtualbox') ? 'VirtualBox' : provider
        compose = FEDORA_BOX_COMPOSES.fetch(version)
        file = "Fedora-Cloud-Base-Vagrant-#{label}-#{version}-#{compose}.#{arch}.vagrant.#{provider}.box"
        base_config['box'] = "fedora-#{version}-#{arch}"
        base_config['box_url'] = "https://download.fedoraproject.org/pub/fedora/linux/releases/#{version}/Cloud/#{arch}/images/#{file}"
      end

      def apply_box_override(node_info, base_config)
        platform = node_info['platform']
        providers = PROVIDER_PLATFORM_BOX_OVERRIDES[platform]
        box = if providers
                providers[@name]
              else
                PLATFORM_BOX_OVERRIDES[platform] || (BOX_OVERRIDES[node_info['ostype']] if node_info['bits'] == '64')
              end
        base_config.merge!(box) if box
      end
    end
  end
end
