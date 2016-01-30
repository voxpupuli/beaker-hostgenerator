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

  def open_file path
    dirname = File.join(path[1, path.length - 2]) # wtf
    filename = File.join(path)
    FileUtils.mkdir_p(dirname)
    return File.open(filename, "w")
  end

  def generate_fixture(dirname, options, spec)
    specopts = options + [spec]
    options_string = specopts.join(" ")
    generated_hash = run_cli_with_options(specopts)

    fixture_hash = {
      "options_string" => options_string,
      "environment_variables" => {},
      "expected_hash" => generated_hash,
      "expected_exception" => nil,
    }
    fixture_yaml = fixture_hash.to_yaml

    fixture_file = open_file([Dir.pwd, @fixture_root] + dirname + [spec])
    fixture_file.write(fixture_yaml)
  end

  def generate_fixtures_using_osinfo(dirname, options=[], bhg_version=0)
    osinfo = get_osinfo(bhg_version)
    osinfo.each_key do |platform_info|
      spec = "#{platform_info}aulcdfm"
      generate_fixture(dirname, options, spec)
    end
  end

  def test_generate_default_fixtures
    # Validates single-host scenarios using all short-form role aliases with no
    # optional flags.
    generate_fixtures_using_osinfo(["default"])
  end

  def test_generate_versioned_fixtures
    # Validates single-host scenarios using all short-form role aliases with the
    # addition of the --osinfo-version flag to indicate which BHG version to
    # generate host configs for.
    [0, 1].each do |bhg_version|
      generate_fixtures_using_osinfo(["osinfo-version-#{bhg_version}"],
                                     ["--osinfo-version", "#{bhg_version}"],
                                     bhg_version)
    end
  end

  def test_generate_pe_dir_fixtures
  end
end
