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

    ROLE_CONFIG = {
      'compile_master' => {
        'main' => {
          'dns_alt_names' => 'puppet',
          'environmentpath' => '/etc/puppetlabs/puppet/environments',
        }
      }
    }

    module_function

    def get_role_config(role)
      ROLE_CONFIG[role] || {}
    end
  end
end
