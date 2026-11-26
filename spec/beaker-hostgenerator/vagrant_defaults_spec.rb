require 'spec_helper'
require 'uri'

require 'beaker-hostgenerator'

module BeakerHostGenerator
  describe 'Vagrant default boxes' do
    let(:generator) { Generator.new }

    %w[vagrant vagrant_libvirt].product([0, 1]).each do |hypervisor, osinfo_version|
      it "uses independent HTTPS box URLs with #{hypervisor} and OS info version #{osinfo_version}" do
        supported = Data.get_platforms(osinfo_version).filter_map do |platform|
          hosts = generator.generate("#{platform}a", hypervisor: hypervisor, osinfo_version: osinfo_version).fetch('HOSTS')
          host = hosts.values.first
          expect(host.fetch('box')).not_to match(%r{\A(?:generic|cloud-image)/})
          url = URI.parse(host.fetch('box_url'))
          expect(url).to be_a(URI::HTTPS)
          expect(url.host).not_to match(/(?:\A|\.)(?:hashicorp\.com|vagrantup\.com|vagrantcloud\.com)\z/i)
          platform
        rescue Exceptions::InvalidNodeSpecError => e
          expect(e.message).to include('{box=...}')
          nil
        end

        shared = %w[
          almalinux8-64 almalinux9-64 almalinux10-64 centos8-64 centos9-64 centos10-64
          debian12-64 debian13-64 fedora44-64 fedora45-64 oracle7-64 oracle8-64 oracle9-64 oracle10-64
          rocky9-64 rocky10-64 rocky9-AARCH64 rocky10-AARCH64 ubuntu2404-64 ubuntu2604-64
        ]
        provider_specific = if hypervisor == 'vagrant'
                              %w[almalinux9-AARCH64 almalinux10-AARCH64 oracle8-AARCH64 oracle9-AARCH64 oracle10-AARCH64 rocky8-64 ubuntu2204-64]
                            else
                              %w[fedora44-AARCH64 fedora45-AARCH64]
                            end
        expect(supported).to match_array(shared + provider_specific)
      end
    end

    %w[vagrant vagrant_libvirt].each do |hypervisor|
      context "with #{hypervisor}" do
        it 'rejects a standalone URL without a box name for Amazon Linux 2023' do
          layout = 'amazon2023-64a{box_url=https://example.com/amazon2023.box}'
          expect { generator.generate(layout, hypervisor: hypervisor) }
            .to raise_error(Exceptions::InvalidNodeSpecError, /No default Vagrant box for amazon2023-64.*\{box=\.\.\.\}/)
        end

        it 'keeps a custom box beside a host with a standalone default' do
          layout = 'amazon2023-64a{box=company/amazon2023,box_url=https://example.com/amazon2023.box}-debian12-64a'
          hosts = generator.generate(layout, hypervisor: hypervisor).fetch('HOSTS')
          expect(hosts.fetch('amazon2023-64-1')).to include(
            'box' => 'company/amazon2023',
            'box_url' => 'https://example.com/amazon2023.box',
          )
          expect(hosts.fetch('debian12-64-1')).to include(
            'box' => 'cloudsoe/debian-12',
            'box_url' => 'https://boxes.cloudsoe.com/cloudsoe/debian-12.json',
          )
        end

        it 'keeps a numeric local box name as a string' do
          host = generator.generate('amazon2023-64a{box=123}', hypervisor: hypervisor).fetch('HOSTS').fetch('amazon2023-64-1')
          expect(host.fetch('box')).to eq('123')
          expect(host).not_to have_key('box_url')
        end
      end
    end

    ['%20', '[company/amazon2023]'].product(%w[vagrant vagrant_libvirt]).each do |box, hypervisor|
      it "rejects an unusable custom box (#{box}) with #{hypervisor}" do
        layout = "amazon2023-64a{box=#{box}}"
        expect { generator.generate(layout, hypervisor: hypervisor) }
          .to raise_error(Exceptions::InvalidNodeSpecError, /No default Vagrant box for amazon2023-64.*\{box=\.\.\.\}/)
      end
    end

    it 'requires a box when Jammy is requested on libvirt' do
      expect { generator.generate('ubuntu2204-64a', hypervisor: 'vagrant_libvirt') }
        .to raise_error(Exceptions::InvalidNodeSpecError, /No default Vagrant box for ubuntu2204-64 with vagrant_libvirt/)
    end
  end
end
