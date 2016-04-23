require 'minitest/autorun'
require 'beaker-hostgenerator/data'

class TestStdout < Minitest::Test

  def setup
    @stderr = StringIO.new
    @stdout = StringIO.new

    $stderr = @stderr
    $stdout = @stdout
  end

  def test_default_list_output
    begin
      BeakerHostGenerator::CLI.new(['--list'])
    rescue BeakerHostGenerator::Exceptions::SafeEarlyExit
    end

    BeakerHostGenerator::Data.get_platforms(0).each do |spec_key|
      assert_match(/.*#{spec_key}.*/, @stdout.string)
    end
  end
end
