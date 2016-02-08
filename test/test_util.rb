require 'minitest/autorun'

require 'beaker-hostgenerator/util'

class TestUtil < Minitest::Test

  def setup
    @stderr = StringIO.new
    @stdout = StringIO.new

    $stderr = @stderr
    $stdout = @stdout
  end

  def test_get_platforms_vmpooler_osinfo_v0
    expected = BeakerHostGenerator::Data::Vmpooler.get_osinfo(0)
    actual = BeakerHostGenerator::Utils.get_platforms('vmpooler', 0)
    assert_equal(expected, actual)
  end

  def test_get_platforms_vmpooler_osinfo_v1
    expected = BeakerHostGenerator::Data::Vmpooler.get_osinfo(1)
    actual = BeakerHostGenerator::Utils.get_platforms('vmpooler', 1)
    assert_equal(expected, actual)
  end
end
