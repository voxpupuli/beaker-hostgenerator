require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/exceptions'
require 'beaker-hostgenerator/roles'
require 'beaker-hostgenerator/hypervisor'

require 'yaml'

module BeakerHostGenerator
  class Generator
    include BeakerHostGenerator::Data
    include BeakerHostGenerator::Exceptions

    # Main host generation entry point, returns a YAML map as a string for the
    # given host specification and optional configuration.
    #
    # @param [Array<String>] tokens The hosts specification input split on '-'.
    #                        For example `["centos6", "64m", "redhat7", "64a"]`.
    # @param [Hash] options General configuration options, such as optional
    #               parameters provided on the command line.
    def generate(tokens, options)
      config = {}.deep_merge(BASE_CONFIG)
      nodeid = Hash.new(1)
      ostype = nil
      bhg_version = options[:osinfo_version] || 0

      tokens.each do |token|
        if is_ostype_token?(token, bhg_version)
          if nodeid[ostype] == 1 and ostype != nil
            raise "Error: no nodes generated for #{ostype}"
          end
          ostype = token
          next
        end

        node_info = __parse_node_info_token(token)

        node_info['ostype'] = ostype
        node_info['nodeid'] = nodeid[ostype]

        host_config = base_host_config()

        [:pe_dir, :pe_ver, :pe_upgrade_dir, :pe_upgrade_ver].each do |option|
          if options[option]
            host_config[option.to_s] = options[option]
          end
        end

        hypervisor = BeakerHostGenerator::Hypervisor.create(node_info, options)
        host_name, host_config =
                   hypervisor.generate_node(node_info, host_config, bhg_version)
        config['CONFIG'].deep_merge!(hypervisor.global_config())

        if PE_USE_WIN32 && ostype =~ /windows/ && node_info['bits'] == "64"
          host_config['ruby_arch'] = 'x86'
          host_config['install_32'] = true
        end

        if not options[:disable_default_role]
          host_config['roles'] = ['agent']
        else
          host_config['roles'] = []
        end

        host_config['roles'].concat __generate_host_roles(node_info)
        host_config['roles'].uniq!

        if not options[:disable_role_config]
          host_config['roles'].each do |role|
            host_config.deep_merge! __get_role_config(role)
          end
        end

        config['HOSTS'][host_name] = host_config
        nodeid[ostype] += 1
      end

      return config.to_yaml
    end

    def __get_role_config(role)
      begin
        r = BeakerHostGenerator::Roles.new
        m = r.method(role)
      rescue NameError
        return {}
      end

      return m.call
    end

    def __parse_node_info_token(token)
      node_info = NODE_REGEX.match(token)

      if node_info
        node_info = Hash[ node_info.names.zip( node_info.captures ) ]
      else
        raise InvalidNodeSpecError.new, "Invalid node_info token: #{token}"
      end

      if node_info['arbitrary_roles']
        node_info['arbitrary_roles'] = node_info['arbitrary_roles'].split(',') || ''
      else
        # Default to empty list to avoid having to check for nil elsewhere
        node_info['arbitrary_roles'] = []
      end

      return node_info
    end

    def __generate_host_roles(node_info)
      roles = []

      node_info['roles'].each_char do |c|
        roles << ROLES[c]
      end

      node_info['arbitrary_roles'].each do |role|
        roles << role
      end

      return roles
    end

  end
end
