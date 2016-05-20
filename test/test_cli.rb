require 'minitest/autorun'

require 'beaker-hostgenerator/cli'

class TestUtil < Minitest::Test

  def test_new_with_list_option
    assert_instance_of(String, BeakerHostGenerator::CLI.new(['--list']).execute)
  end

  def test_version_option
    assert_equal(BeakerHostGenerator::Version::STRING,
                 BeakerHostGenerator::CLI.new(['--version']).execute)
  end
end
