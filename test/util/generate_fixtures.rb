require "minitest/autorun"

require 'beaker-hostgenerator'

require 'util/generator_helpers'

class GenerateFixtures < Minitest::Test
  include GeneratorTestHelpers

  def setup
    @fixture_root = 'test/fixtures/'
    @simple_roles = ["a", "u", "l", "c", "d", "f", "m", "aulcdfm"]
  end

  def test_generate_default_fixtures
    # Validates single-host scenarios using all short-form role aliases with no
    # optional flags.
    generate_fixtures_using_osinfo(["default"], @simple_roles.cycle)
  end

  def test_generate_versioned_fixtures
    # Validates single-host scenarios using all short-form role aliases with the
    # addition of the --osinfo-version flag to indicate which BHG version to
    # generate host configs for.
    [0, 1].each do |bhg_version|
      generate_fixtures_using_osinfo(["osinfo-version-#{bhg_version}"],
                                     @simple_roles.cycle,
                                     ["--osinfo-version", "#{bhg_version}"],
                                     bhg_version)
    end
  end

  def test_generate_pe_dir_fixtures
  end
end
