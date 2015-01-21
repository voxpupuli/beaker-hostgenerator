module GenConfig
  module Data
    include GenConfig::Utils

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

    # This regex determines if we're looking at a OS token or a node
    # token. If a node token, it captures the platform bittage and the
    # roles that node should have.
    NODE_REGEX=/\A(?<bits>\d+)(?<roles>[uacldfm]*)\Z/

    BASE_CONFIG = {
      'HOSTS' => {},
      'CONFIG' => {
        'nfs_server' => 'none',
        'consoleport' => 443,
      }
    }
  end
end
