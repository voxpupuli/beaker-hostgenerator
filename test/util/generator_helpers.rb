require "yaml"

require 'beaker-hostgenerator'

module GeneratorTestHelpers
  def run_cli_with_options options = []
    STDERR.reopen("stderr.txt", "w")
    cli = BeakerHostGenerator::CLI.new(options)
    yaml_string = cli.execute

    hash = YAML.load(yaml_string)
    return hash
  end
end
