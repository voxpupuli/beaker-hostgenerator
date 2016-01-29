require "minitest/autorun"
require "yaml"

module GeneratorTestHelpers
  def run_cli_with_options options = []
    # Calls beaker-hostgenerator with the given options, then reads the
    # resulting yaml stdout, then returns a hash of that data structure to be
    # asserted upon.
    options.insert(0, "beaker-hostgenerator")
    command = options.join(" ")
    stdin, stdout, stderr = Open3.popen3(String(command))
    hash = YAML.load(stdout.read())
    return hash
  end
end

class TestGenerator < Minitest::Test
  include GeneratorTestHelpers

  def setup
    @default_options = [
      'centos6-64mdca',
    ]
  end

  def test_default_options
    hash = run_cli_with_options(@default_options)
    hosts = hash['HOSTS']

    assert_includes(hosts, "centos6-64-1")
    centos6 = hosts['centos6-64-1']
    ["master", "database", "dashboard", "agent"].each do |role| 
      assert_includes(centos6['roles'], role)
    end
  end

  def test_pe_dir_option
    skip "pe_dir option not yet tested"
  end

end
