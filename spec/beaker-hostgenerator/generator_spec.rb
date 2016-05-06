require 'find'

require 'spec_helper'

require 'beaker-hostgenerator'
require 'util/generator_helpers'

module BeakerHostGenerator
      describe Generator do
        let(:generator) { BeakerHostGenerator::Generator.new }

        describe '__generate_host_roles' do
          it 'Generates a list of roles' do
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
              expect( generator.__generate_host_roles(node_info) ).to eq( roles )
            end
          end
        end

        shared_examples "fixtures" do |fixture_hash|
          arguments = fixture_hash["arguments_string"]
          it "beaker-hostgenerator #{arguments}" do
            arguments = arguments.split
            STDERR.reopen("stderr.txt", "w")
            fixture_hash['environment_variables'].each do |key, value|
              ENV[key] = value
            end
            cli = BeakerHostGenerator::CLI.new(arguments)
            test_hash = YAML.load(cli.execute)
            fixture_hash['environment_variables'].each_key do |key|
              ENV[key] = nil
            end
            expect(test_hash).to eq(fixture_hash["expected_hash"])
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

      end
end
