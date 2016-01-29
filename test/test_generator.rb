require "minitest/autorun"

class TestGenerator < Minitest::Test
  def setup
    @default_options = {
      list_platforms_and_roles: false,
      disable_default_role: false,
      disable_role_config: false,
      hypervisor: 'vmpooler',
    }
  end

  def test_pe_dir_option
    skip "pe_dir option not yet tested"
  end

end
