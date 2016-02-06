module BeakerHostGenerator
  module Data

    def pe_version
      ENV['pe_version']
    end

    def pe_family
      ENV['pe_family']
    end

    def pe_upgrade_version
      ENV['pe_upgrade_version']
    end

    def pe_upgrade_family
      ENV['pe_upgrade_family']
    end

    PE_USE_WIN32=ENV['pe_use_win32']

    ROLES = {
      'a' => 'agent',
      'u' => 'ca',
      'l' => 'classifier',
      'c' => 'dashboard',
      'd' => 'database',
      'f' => 'frictionless',
      'm' => 'master',
    }

    # Capture role and bit width information about the node.
    #
    # Examples node specs and their resulting roles
    #
    #  64compile_master,zuul,meow.a
    #   * compile_master
    #   * zuul
    #   * meow
    #   * agent
    #
    #  32herp.cdma
    #   * herp
    #   * dashboard
    #   * database
    #   * master
    #   * agent
    #
    #  64dashboard,master,agent,database.
    #   * dashboard
    #   * master
    #   * agent
    #   * database
    #
    NODE_REGEX=/\A(?<bits>\d+)((?<arbitrary_roles>([[:lower:]_]*|\,)*)\.)?(?<roles>[uacldfm]*)\Z/

    BASE_CONFIG = {
      'HOSTS' => {},
      'CONFIG' => {
        'nfs_server' => 'none',
        'consoleport' => 443,
      }
    }
  end
end
