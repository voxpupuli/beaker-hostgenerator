require 'find'

require 'spec_helper'

require 'beaker-hostgenerator'
require 'util/generator_helpers'

module BeakerHostGenerator
  describe Generator do
    let(:generator) { BeakerHostGenerator::Generator.new }

    describe 'get_host_roles' do
      it 'Expands default roles and merges in arbitrary roles' do
        {
          {
            "roles" => "aulcdfm",
            "arbitrary_roles" => [],
          } => [
            'agent',
            'ca',
            'classifier',
            'dashboard',
            'database',
            'frictionless',
            'master',
          ],
          {
            "roles" => "a",
            "arbitrary_roles" => ["meow","hello","compile_master"],
          } => [
            'agent',
            'meow',
            'hello',
            'compile_master',
          ],
          {
            "roles" => "",
            "arbitrary_roles" => ["compile_master"],
          } => [
            'compile_master'
          ],
          {
            "roles" => "",
            "arbitrary_roles" => [],
          } => [],
        }.each do |node_info, roles|
          expect( generator.get_host_roles(node_info) ).to eq( roles )
        end
      end
    end

    shared_examples "fixtures" do |fixture_hash|
      arguments = fixture_hash["arguments_string"]
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

    context "Fixtures" do
      Find.find 'test/fixtures' do |f|
        context "#{f}" do
          if File.directory?(f)
            next
          end
          include_examples "fixtures", YAML.load_file(f)
        end
      end
    end

    context "pe_dir for versions < 2021.0" do
      let(:dev_version) { '2019.8.0-rc4-11-g123abcd' }
      let(:dev_version_no_rc) { '2019.8.0-1-g123abcd' }
      let(:pez_version) { '2019.8.0-rc4-11-g123abcd-PEZ_foo' }
      let(:release_version) { '2019.8.2' }
      let(:rc_version) { '2019.8.0-rc4' }

      it "returns ci-ready for a dev version" do
        expect(BeakerHostGenerator::Data.pe_dir(dev_version)).to match(%r{2019\.8/ci-ready})
        expect(BeakerHostGenerator::Data.pe_dir(dev_version_no_rc)).to match(%r{2019\.8/ci-ready})
      end

      it "returns archives/releases for a release version" do
        expect(BeakerHostGenerator::Data.pe_dir(release_version)).to match(%r{archives/releases/2019\.8})
      end

      it "returns archives/internal for an rc version" do
        expect(BeakerHostGenerator::Data.pe_dir(rc_version)).to match(%r{archives/internal/2019\.8})
      end

      it "returns feature/ci-ready for a PEZ version" do
        expect(BeakerHostGenerator::Data.pe_dir(pez_version)).to match(%r{2019\.8/feature/ci-ready})
      end

      it "returns nil if version is nil" do
        expect(BeakerHostGenerator::Data.pe_dir(nil)).to be_nil
      end

      it "returns nil if version is an empty string" do
        expect(BeakerHostGenerator::Data.pe_dir('')).to be_nil
      end

      it "returns an empty string if version isn't parseable" do
        expect(BeakerHostGenerator::Data.pe_dir('wtf')).to eq('')
      end
    end

    context "pe_dir for versions >= 2021.0" do
      let(:dev_version) { '2021.0.0-rc4-11-g123abcd' }
      let(:dev_version_no_rc) { '2021.0.0-1-g123abcd' }
      let(:pez_version) { '2021.0.0-rc4-11-g123abcd-PEZ_foo' }
      let(:release_version) { '2021.0.0' }
      let(:rc_version) { '2021.0.0-rc4' }

      it "returns main/ci-ready for a dev version" do
        expect(BeakerHostGenerator::Data.pe_dir(dev_version)).to match(%r{main/ci-ready})
        expect(BeakerHostGenerator::Data.pe_dir(dev_version_no_rc)).to match(%r{main/ci-ready})
      end

      it "returns archives/releases/<version> for a release version" do
        expect(BeakerHostGenerator::Data.pe_dir(release_version)).to match(%r{archives/releases/2021\.0\.0})
      end

      it "returns archives/internal/main for an rc version" do
        expect(BeakerHostGenerator::Data.pe_dir(rc_version)).to match(%r{archives/internal/2021.0})
      end

      it "returns main/feature/ci-ready for a PEZ version" do
        expect(BeakerHostGenerator::Data.pe_dir(pez_version)).to match('main/feature')
      end
    end
  end
end
