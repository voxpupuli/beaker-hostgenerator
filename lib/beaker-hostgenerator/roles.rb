module BeakerHostGenerator
  module Roles

    ROLES = {
      'a' => 'agent',
      'u' => 'ca',
      'l' => 'classifier',
      'c' => 'dashboard',
      'd' => 'database',
      'f' => 'frictionless',
      'm' => 'master',
    }

    CM_CONFIG = { 'main' => {
                    'dns_alt_names' => 'puppet',
                    'environmentpath' => '/etc/puppetlabs/puppet/environments',
                  }
                }

    ROLE_CONFIG = {
      'compile_master' => CM_CONFIG,
      'pe_compiler' => CM_CONFIG,
    }

    module_function

    def get_role_config(role)
      ROLE_CONFIG[role] || {}
    end
  end
end
