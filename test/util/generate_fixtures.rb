require "yaml"

require "minitest/autorun"

require 'beaker-hostgenerator'
require 'beaker-hostgenerator/data/vmpooler'
require 'beaker-hostgenerator/data'

require 'util/generator_helpers'

class GenerateFixtures < Minitest::Test
  include GeneratorTestHelpers
  include BeakerHostGenerator::Data
  include BeakerHostGenerator::Data::Vmpooler

  def setup
    @fixture_root = 'test/fixtures/'
  end

  def open_file *path
    path_len = path.length
    dirname = File.join(path[1, path_len - 2])
    filename = File.join(path)
    FileUtils.mkdir_p(dirname)
    return File.open(filename, "w")
  end

  def test_generate_versioned_fixtures
    [0, 1].each do |bhg_version|
      osinfo = get_osinfo(bhg_version)
      osinfo.each_key do |spec_name|
        fixture_file = open_file(Dir.pwd,
                                @fixture_root,
                                "bhg-version-#{bhg_version}",
                                "default",
                                spec_name)
        options = ["--osinfo-version", "#{bhg_version}", "#{spec_name}mdca"]
        options_string = options.join(" ")
        generated_hash = run_cli_with_options(options)

        fixture_hash = {
          "options_string" => options_string,
          "environment_variables" => {},
          "expected_hash" => generated_hash,
          "expected_exception" => nil,
        }
        fixture_yaml = fixture_hash.to_yaml
        fixture_file.write(fixture_yaml)
      end
    end
  end
end
