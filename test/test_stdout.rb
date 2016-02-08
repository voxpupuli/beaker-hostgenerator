require 'minitest/autorun'

class TestStdout < Minitest::Test

  def setup
    @stderr = StringIO.new
    @stdout = StringIO.new

    $stderr = @stderr
    $stdout = @stdout
  end

  def test_default_list_output
    BeakerHostGenerator::CLI.new(['--list'])

    osinfo = BeakerHostGenerator::Data::Vmpooler.get_osinfo()
    osinfo.each_key do |spec_key|
      assert_match(/.*#{spec_key}.*/, @stdout.string)
    end
  end
end
