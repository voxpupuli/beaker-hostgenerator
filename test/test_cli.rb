require 'minitest/autorun'

require 'beaker-hostgenerator/cli'

class TestUtil < Minitest::Test

  def setup
    @stderr = StringIO.new
    @stdout = StringIO.new

    $stderr = @stderr
    $stdout = @stdout
  end

  def test_new_with_list_option
    assert_raises(BeakerHostGenerator::Exceptions::SafeEarlyExit) do
      BeakerHostGenerator::CLI.new(['--list'])
    end
  end
end
