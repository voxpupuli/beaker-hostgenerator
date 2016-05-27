require "yaml"

require 'beaker-hostgenerator'
require 'beaker-hostgenerator/data'

module GeneratorTestHelpers
  include BeakerHostGenerator::Data

  def run_cli_with_options(options=[])
    STDERR.reopen("stderr.txt", "w")
    cli = BeakerHostGenerator::CLI.new(options)
    yaml_string = cli.execute

    hash = YAML.load(yaml_string)
    return hash
  end

  def open_file(path)
    # Takes a list of path elements.
    # Returns a file object where the basename of the file is the last path
    # element.
    dirname = File.join(path[1, path.length - 2]) # wtf
    filename = File.join(path)
    FileUtils.mkdir_p(dirname)
    return File.open(filename, "w")
  end

  def generate_fixture(relative_path, options, spec, environment_variables={})
    specopts = options + [spec]
    arguments_string = specopts.join(" ")

    environment_variables.each do |key, value| 
      ENV[key] = value
    end
    generated_hash = run_cli_with_options(specopts)
    environment_variables.each_key do |key|
      ENV[key] = nil
    end

    fixture_hash = {
      "arguments_string" => arguments_string,
      "environment_variables" => environment_variables,
      "expected_hash" => generated_hash,
      "expected_exception" => nil,
    }
    fixture_yaml = fixture_hash.to_yaml

    fixture_file = open_file([Dir.pwd, @fixture_root] + relative_path + [spec])
    fixture_file.write(fixture_yaml)
  end

  def generate_fixtures_using_osinfo(relative_path,
                                     role_enumerator,
                                     options=[],
                                     bhg_version=0)
    platforms = get_platforms(bhg_version)
    platforms.each do |platform_info|
      role = role_enumerator.next
      spec = "#{platform_info}" + role
      generate_fixture(relative_path, options, spec)
    end
  end

end

class FixtureGenerator
  include GeneratorTestHelpers

  def initialize
    @fixture_root = 'test/fixtures/generated/'
    @simple_roles = ["a", "u", "l", "c", "d", "f", "m", "aulcdfm"]
  end

  def generate
    # Validates single-host scenarios using all short-form role aliases with no
    # optional flags'
    generate_fixtures_using_osinfo(['default'], @simple_roles.cycle, [])

    # Validates the use of environment variables to set various pe options.
    [
      {'case_name' => 'pe_version_and_pe_family',
       'environment_variables' => {
         'pe_version' => '6.6.6',
         'pe_upgrade_version' => '6.6.6',
         'pe_family' => '6.6.6',
         'pe_upgrade_family' => '6.6.6',
       }
      },
      {'case_name' => 'pe_version_and_pe_family_upgrade_only',
       'environment_variables' => {
        'pe_upgrade_version' => '6.6.6',
        'pe_upgrade_family' => '6.6.6',
       }
      },
      {'case_name' => 'pe_version_and_pe_family_no_upgrade',
       'environment_variables' => {
         'pe_version' => '6.6.6',
         'pe_family' => '6.6.6',
       }
      },
    ].each do |fixture_hash|
      case_name = fixture_hash['case_name']
      environment_variables = fixture_hash['case_name']
      generate_fixture(['environment_variable_tests', fixture_hash['case_name']],
                       [],
                       'centos6-32a',
                       fixture_hash['environment_variables'])
    end

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

    # Validates multi-platform specs
    get_platforms(0).zip(
      get_platforms(1).reverse,
      get_platforms(0),
      @simple_roles.cycle,
      @simple_roles.reverse.cycle
    ) do |p1, p2, p3, r1, r2|
      generate_fixture(["multiplatform"], [], "#{p1}#{r1}-#{p2}-#{p3}#{r2}")
    end
  end
end
