require "yaml"

require 'beaker-hostgenerator'
require 'beaker-hostgenerator/data/vmpooler'
require 'beaker-hostgenerator/data'

module GeneratorTestHelpers
  include BeakerHostGenerator::Data
  include BeakerHostGenerator::Data::Vmpooler

  def run_cli_with_options options = []
    STDERR.reopen("stderr.txt", "w")
    cli = BeakerHostGenerator::CLI.new(options)
    yaml_string = cli.execute

    hash = YAML.load(yaml_string)
    return hash
  end

  def open_file path
    # Takes a list of path elements.
    # Returns a file object where the basename of the file is the last path
    # element.
    dirname = File.join(path[1, path.length - 2]) # wtf
    filename = File.join(path)
    FileUtils.mkdir_p(dirname)
    return File.open(filename, "w")
  end

  def generate_fixture(relative_path, options, spec)
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

    fixture_file = open_file([Dir.pwd, @fixture_root] + relative_path + [spec])
    fixture_file.write(fixture_yaml)
  end

  def generate_fixtures_using_osinfo(relative_path,
                                     options=[],
                                     bhg_version=0,
                                     )
    osinfo = get_osinfo(bhg_version)
    osinfo.each_key do |platform_info|
      spec = "#{platform_info}aulcdfm"
      generate_fixture(relative_path, options, spec)
    end
  end

end
