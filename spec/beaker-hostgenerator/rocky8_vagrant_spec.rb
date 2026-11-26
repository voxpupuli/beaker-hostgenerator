require 'spec_helper'

require 'beaker-hostgenerator'

module BeakerHostGenerator
  describe 'Rocky Linux 8 Vagrant boxes' do
    let(:generator) { Generator.new }

    it 'requires a custom box for x86_64 libvirt' do
      expect { generator.generate('rocky8-64a', hypervisor: 'vagrant_libvirt') }
        .to raise_error(
          Exceptions::InvalidNodeSpecError,
          /rocky8-64 with vagrant_libvirt.*BIOS.*\{box=\.\.\.\}/,
        )
    end

    it 'still requires a box name with an explicit libvirt URL' do
      layout = 'rocky8-64a{box_url=https://example.com/rocky8-libvirt.box}'
      expect { generator.generate(layout, hypervisor: 'vagrant_libvirt') }
        .to raise_error(Exceptions::InvalidNodeSpecError, /Specify a provider-compatible box/)
    end

    it 'lists the supported architecture for the Rocky Linux 8 VirtualBox default' do
      expect { generator.generate('rocky8-AARCH64a', hypervisor: 'vagrant') }
        .to raise_error(Exceptions::InvalidNodeSpecError, /Supported architectures: 64\./)
    end
  end
end
