require "find"
require "yaml"

require "minitest/autorun"

require 'util/generator_helpers'

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

  def test_fixtures
    Find.find 'test/fixtures' do |f|
      if File.directory?(f)
        next
      end

      fixture_hash = YAML.load_file(f)

      options = fixture_hash["options_string"]
      options = options.split
      test_hash = run_cli_with_options(options)
      assert_equal(fixture_hash["expected_hash"], test_hash)
    end
  end
end
