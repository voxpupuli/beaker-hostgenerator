#!/usr/bin/env ruby

$LOAD_PATH.unshift(
  File.expand_path(File.dirname(File.dirname(__FILE__)), 'lib'),
  File.expand_path(File.dirname(File.dirname(__FILE__)), 'test')
)

require 'beaker-hostgenerator'
require 'util/generator_helpers'

class FixtureGenerator
  include GeneratorTestHelpers

  def initialize
    @fixture_root = 'test/fixtures/'
    @simple_roles = ["a", "u", "l", "c", "d", "f", "m", "aulcdfm"]
  end

  def generate
    # Validates single-host scenarios using all short-form role aliases with no
    # optional flags'
    generate_fixtures_using_osinfo(['default'], @simple_roles.cycle, [])

    # Validates single-host scenarios using all short-form role aliases with the
    # addition of the --osinfo-version flag to indicate which BHG version to
    # generate host configs for.
    [0, 1].each do |bhg_version|
      generate_fixtures_using_osinfo(["osinfo-version-#{bhg_version}"],
                                     @simple_roles.cycle,
                                     ["--osinfo-version", "#{bhg_version}"],
                                     bhg_version)
    end

    # Validates the use of the pe ver/dir type options.
    [
      {
        'path' => ['pe_upgrade_ver'],
        'options' => ['--pe_upgrade_ver', '2020.7.3'],
        'spec' => 'centos6-64mdc'
        },
      {
        'path' => ['pe_ver'],
        'options' => ['--pe_ver', '2020.7'],
        'spec' => 'centos6-64mdc'
        },
      {
        'path' => ['pe_upgrade_dir'],
        'options' => ['--pe_upgrade_dir', '/opt/whatever'],
        'spec' => 'centos6-64mdc'
        },
      {
        'path' => ['pe_dir'],
        'options' => ['--pe_dir', '/opt/hello'],
        'spec' => 'centos6-64mdc'
        }
      ].each do |fixture_info|
      generate_fixture(fixture_info['path'],
                       fixture_info['options'],
                       fixture_info['spec'])
    end
  end
end

fixgen = FixtureGenerator.new
fixgen.generate
