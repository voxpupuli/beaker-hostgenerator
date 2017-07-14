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

    context "pe_dir" do
      let(:dev_version) { '2017.3.0-rc4-11-g123abcd' }
      let(:dev_version_no_rc) { '2017.3.0-1-g123abcd' }
      let(:pez_version) { '2017.3.0-rc4-11-g123abcd-PEZ_foo' }
      let(:release_version) { '2017.2.2' }
      let(:rc_version) { '2017.3.0-rc4' }

      it "returns ci-ready for a dev version" do
        expect(BeakerHostGenerator::Data.pe_dir(dev_version, '2017.3')).to match(%r{2017\.3/ci-ready})
        expect(BeakerHostGenerator::Data.pe_dir(dev_version_no_rc, '2017.3')).to match(%r{2017\.3/ci-ready})
      end

      it "returns ci-ready even if pe_family matches" do
        expect(BeakerHostGenerator::Data.pe_dir(dev_version, dev_version)).to match(%r{2017\.3/ci-ready})
        expect(BeakerHostGenerator::Data.pe_dir(dev_version_no_rc, dev_version_no_rc)).to match(%r{2017\.3/ci-ready})
      end

      it "returns archives/releases for a release version" do
        expect(BeakerHostGenerator::Data.pe_dir(release_version, '2017.3')).to match(%r{archives/releases/2017\.2})
      end

      it "returns archives/internal for an rc version" do
        expect(BeakerHostGenerator::Data.pe_dir(rc_version, '2017.3')).to match(%r{archives/internal/2017\.3})
      end

      it "returns archives/internal for an rc version even if pe_family matches" do
        expect(BeakerHostGenerator::Data.pe_dir(rc_version, rc_version)).to match(%r{archives/internal/2017\.3})
      end

      it "returns feature/ci-ready for a PEZ version" do
        expect(BeakerHostGenerator::Data.pe_dir(pez_version, '2017.3')).to match(%r{2017\.3/feature/ci-ready})
      end

      it "(backwards compatible) returns archives/release if pe_version matches pe_family" do
        expect(BeakerHostGenerator::Data.pe_dir(release_version, release_version)).to match(%r{archives/releases/2017\.2\.2})
      end

      it "(backwords compatible) returns nil if eiher argument is nil" do
        expect(BeakerHostGenerator::Data.pe_dir(nil, '2017.3')).to be_nil
        expect(BeakerHostGenerator::Data.pe_dir(dev_version, nil)).to be_nil
      end
    end
  end
end
