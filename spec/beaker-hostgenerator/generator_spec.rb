require 'find'

require 'spec_helper'

require 'beaker-hostgenerator'
require 'util/generator_helpers'

module BeakerHostGenerator
  describe Generator do
    let(:generator) { BeakerHostGenerator::Generator.new }

    describe 'generate' do
      it 'preserves arbitrary role names containing digits' do
        config = generator.generate('centos9-64abc,def6,default.a', hypervisor: 'vmpooler')
        expect(config.fetch('HOSTS').fetch('centos9-64-1').fetch('roles')).to eq(%w[agent abc def6 default])
      end
    end

    describe 'get_host_roles' do
      it 'Expands default roles and merges in arbitrary roles' do
        {
          {
            'roles' => 'aulcdfm',
            'arbitrary_roles' => [],
          } => %w[
            agent
            ca
            classifier
            dashboard
            database
            frictionless
            master
          ],
          {
            'roles' => 'a',
            'arbitrary_roles' => %w[meow hello compile_master],
          } => %w[
            agent
            meow
            hello
            compile_master
          ],
          {
            'roles' => '',
            'arbitrary_roles' => ['compile_master'],
          } => [
            'compile_master',
          ],
          {
            'roles' => '',
            'arbitrary_roles' => [],
          } => [],
        }.each do |node_info, roles|
          expect(generator.get_host_roles(node_info)).to eq(roles)
        end
      end
    end

    shared_examples 'fixtures' do |fixture_hash|
      arguments = fixture_hash['arguments_string']
      it "beaker-hostgenerator #{arguments}" do
        arguments = arguments.split
        fixture_hash['environment_variables'].each do |key, value|
          ENV[key] = value
        end

        cli = BeakerHostGenerator::CLI.new(arguments)
        if fixture_hash['expected_exception']
          # Turn fully-qualified classname string into actual Class object.
          # We have to manually descend into each Module that makes up the
          # fully-qualified path to the error class.
          qualified_classname = fixture_hash['expected_exception'].split('::')
          expected_class = qualified_classname.reduce(Object) do |accum, e|
            accum.const_get(e)
          end
          expect { cli.execute }.to raise_error(expected_class)
        else
          test_hash = YAML.load(cli.execute)
          expect(test_hash).to eq(fixture_hash['expected_hash'])
        end

        fixture_hash['environment_variables'].each_key do |key|
          ENV[key] = nil
        end
      end
    end

    context 'Fixtures' do
      Find.find 'test/fixtures' do |f|
        context "#{f}" do
          next if File.directory?(f)

          it_behaves_like 'fixtures', YAML.load_file(f)
        end
      end
    end

    context 'OpenBSD backends' do
      include GeneratorTestHelpers

      vagrant_backends = %w[vagrant vagrant_libvirt]
      container_backends = %w[docker container container_docker container_podman container_swarm]
      template_backends = %w[vmpooler abs]

      { '79' => '7.9', '80' => '8.0' }.each do |short_release, release|
        context "with OpenBSD #{release}" do
          let(:layout) { "openbsd#{short_release}-64a" }

          it 'configures an existing host' do
            config = run_cli_with_options(['--hypervisor', 'none', "#{layout}{ip=192.0.2.10}"])
            host = config.fetch('HOSTS').values.first
            expect(host).to include('platform' => "openbsd-#{release}-amd64", 'ip' => '192.0.2.10', 'hypervisor' => 'none')
          end

          vagrant_backends.each do |backend|
            it "requires an explicit box for #{backend}" do
              expect { run_cli_with_options(['--hypervisor', backend, layout]) }
                .to raise_error(Exceptions::InvalidNodeSpecError, /Specify a provider-compatible box/)
            end

            it "preserves an explicit box and URL for #{backend}" do
              box_url = 'https://example.com/openbsd.box'
              config = run_cli_with_options(['--hypervisor', backend, "#{layout}{box=custom/openbsd,box_url=#{box_url}}"])
              expect(config.fetch('HOSTS').values.first)
                .to include('box' => 'custom/openbsd', 'box_url' => box_url, 'hypervisor' => backend)
            end
          end

          container_backends.each do |backend|
            it "rejects #{backend} even with a custom image" do
              expect { run_cli_with_options(['--hypervisor', backend, "#{layout}{image=custom/openbsd}"]) }
                .to raise_error(Exceptions::InvalidNodeSpecError, /Use --hypervisor none/)
            end
          end

          template_backends.each do |backend|
            it "preserves an explicit template for #{backend}" do
              config = run_cli_with_options(['--hypervisor', backend, "#{layout}{template=custom-openbsd}"])
              expect(config.fetch('HOSTS').values.first).to include('template' => 'custom-openbsd', 'hypervisor' => backend)
            end
          end
        end
      end
    end

    context 'pe_dir for versions < 2021.0' do
      let(:dev_version) { '2019.8.0-rc4-11-g123abcd' }
      let(:dev_version_no_rc) { '2019.8.0-1-g123abcd' }
      let(:pez_version) { '2019.8.0-rc4-11-g123abcd-PEZ_foo' }
      let(:release_version) { '2019.8.2' }
      let(:rc_version) { '2019.8.0-rc4' }

      it 'returns ci-ready for a dev version' do
        expect(BeakerHostGenerator::Data.pe_dir(dev_version)).to include('2019.8/ci-ready')
        expect(BeakerHostGenerator::Data.pe_dir(dev_version_no_rc)).to include('2019.8/ci-ready')
      end

      it 'returns archives/releases for a release version' do
        expect(BeakerHostGenerator::Data.pe_dir(release_version)).to include('archives/releases/2019.8')
      end

      it 'returns archives/internal for an rc version' do
        expect(BeakerHostGenerator::Data.pe_dir(rc_version)).to include('archives/internal/2019.8')
      end

      it 'returns feature/ci-ready for a PEZ version' do
        expect(BeakerHostGenerator::Data.pe_dir(pez_version)).to include('2019.8/feature/ci-ready')
      end

      it 'returns nil if version is nil' do
        expect(BeakerHostGenerator::Data.pe_dir(nil)).to be_nil
      end

      it 'returns nil if version is an empty string' do
        expect(BeakerHostGenerator::Data.pe_dir('')).to be_nil
      end

      it "returns an empty string if version isn't parseable" do
        expect(BeakerHostGenerator::Data.pe_dir('wtf')).to eq('')
      end
    end

    context 'pe_dir for versions >= 2025.0' do
      let(:dev_version) { '2025.0.0-rc4-11-g123abcd' }
      let(:dev_version_no_rc) { '2025.0.0-1-g123abcd' }
      let(:pez_version) { '2025.0.0-rc4-11-g123abcd-pez_foo' } # Some jobs use "PEZ" and some "pez"
      let(:release_version) { '2025.0.0' }
      let(:rc_version) { '2025.0.0-rc4' }

      it 'returns main/ci-ready for a dev version' do
        expect(BeakerHostGenerator::Data.pe_dir(dev_version)).to include('main/ci-ready')
        expect(BeakerHostGenerator::Data.pe_dir(dev_version_no_rc)).to include('main/ci-ready')
      end

      it 'returns archives/releases/<version> for a release version' do
        expect(BeakerHostGenerator::Data.pe_dir(release_version)).to include('archives/releases/2025.0.0')
      end

      it 'returns archives/internal/main for an rc version' do
        expect(BeakerHostGenerator::Data.pe_dir(rc_version)).to match(%r{archives/internal/2025.0})
      end

      it 'returns main/feature/ci-ready for a PEZ version' do
        expect(BeakerHostGenerator::Data.pe_dir(pez_version)).to match('main/feature')
      end
    end
  end
end
