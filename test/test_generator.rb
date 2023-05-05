require 'find'
require 'yaml'

require 'minitest/autorun'

require 'util/generator_helpers'

class TestGenerator < Minitest::Test
  include GeneratorTestHelpers

  def setup
    @default_options = [
      'centos9-64mdca',
    ]
  end

  def test_default_options
    hash = run_cli_with_options(@default_options)
    hosts = hash['HOSTS']

    assert_includes(hosts, 'centos9-64-1')
    centos9 = hosts['centos9-64-1']

    %w[master database dashboard agent].each do |role|
      assert_includes(centos9['roles'], role)
    end
  end
end
