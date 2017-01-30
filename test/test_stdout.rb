require 'minitest/autorun'
require 'beaker-hostgenerator/cli'
require 'beaker-hostgenerator/data'

class TestStdout < Minitest::Test

  def setup
    @stderr = StringIO.new
    @stdout = StringIO.new

    $stderr = @stderr
    $stdout = @stdout
  end

  def test_default_list_output
    BeakerHostGenerator::CLI.new(['--list']).execute!
    BeakerHostGenerator::Data.get_platforms(0).each do |spec_key|
      assert_match(/.*#{spec_key}.*/, @stdout.string)
    end
  end

  def test_ubuntu_host_generation_output
    BeakerHostGenerator::CLI.new(['ubuntu1404-64default.mdcal-ubuntu1404-64af']).execute!
    assert_match(/WARNING: Starting with beaker-hostgenerator 1\.x platform strings for "el" hosts/, @stderr.string)
  end
end
