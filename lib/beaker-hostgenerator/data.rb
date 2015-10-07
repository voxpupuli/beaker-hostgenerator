module GenConfig
  module Data

    # Pull various informations out of the environment.
    PE_VERSION=ENV['pe_version']
    PE_FAMILY=ENV['pe_family']
    PE_UPGRADE_VERSION=ENV['pe_upgrade_version']
    PE_UPGRADE_FAMILY=ENV['pe_upgrade_family']

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
