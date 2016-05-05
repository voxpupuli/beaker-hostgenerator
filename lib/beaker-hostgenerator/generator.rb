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

        # Build node host name
        platform = "#{ostype}-#{node_info['bits']}"
        host_name = "#{platform}-#{nodeid[ostype]}"

        node_info['platform'] = platform
        node_info['ostype'] = ostype
        node_info['nodeid'] = nodeid[ostype]

        host_config = base_host_config(options)

        # Delegate to the hypervisor
        hypervisor = BeakerHostGenerator::Hypervisor.create(node_info, options)
        host_config = hypervisor.generate_node(node_info, host_config, bhg_version)
        config['CONFIG'].deep_merge!(hypervisor.global_config())

        # Merge in any arbitrary key-value host settings. Treat the 'hostname'
        # setting specially, and don't merge it in as an arbitrary setting.
        arbitrary_settings = node_info['host_settings']
        if arbitrary_settings['hostname']
          host_name = arbitrary_settings['hostname']
          arbitrary_settings.delete('hostname')
        end
        host_config.merge!(arbitrary_settings)

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

      if node_info['host_settings']
        node_info['host_settings'] =
          __settings_string_to_map(node_info['host_settings'])
      else
        node_info['host_settings'] = {}
      end

      return node_info
    end

    # Transforms the arbitrary host settings map from a string representation
    # to a proper hash map data structure. The string is expected to be of the
    # form "{key1=value1,key2=value2,...}".
    def __settings_string_to_map(host_settings)
      Hash[
        host_settings.
        delete('{}').
        split(',').
        map { |keyvalue| keyvalue.split('=') }
      ]
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
