require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/roles'
require 'beaker-hostgenerator/hypervisor'
require 'beaker-hostgenerator/parser'

module BeakerHostGenerator
  class Generator
    include BeakerHostGenerator::Data
    include BeakerHostGenerator::Parser
    include BeakerHostGenerator::Roles

    # Main host generation entry point, returns a Ruby map for the given host
    # specification and optional configuration.
    #
    # @param layout [String] The raw hosts specification user input.
    #                        For example `"centos6-64m-redhat7-64a"`.
    # @param options [Hash] Global, optional configuration such as the default
    #                       hypervisor or OS info version.
    #
    # @returns [Hash] A complete Ruby map as defining the HOSTS and CONFIG
    #                 sections as required by Beaker.
    def generate(layout, options)
      layout = prepare(layout)
      tokens = tokenize_layout(layout)
      config = {}.deeper_merge(BASE_CONFIG)
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

        node_info = parse_node_info_token(token)

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
        config['CONFIG'].deeper_merge!(hypervisor.global_config())

        # Merge in any arbitrary key-value host settings. Treat the 'hostname'
        # setting specially, and don't merge it in as an arbitrary setting.
        arbitrary_settings = node_info['host_settings']
        host_name = arbitrary_settings.delete('hostname') if
          arbitrary_settings.has_key?('hostname')
        host_config.merge!(arbitrary_settings)

        if PE_USE_WIN32 && ostype =~ /windows/ && node_info['bits'] == "64"
          host_config['ruby_arch'] = 'x86'
          host_config['install_32'] = true
        end

        generate_host_roles!(host_config, node_info, options)

        config['HOSTS'][host_name] = host_config
        nodeid[ostype] += 1
      end

      # Merge in global configuration settings after the hypervisor defaults
      if options[:global_config]
        decoded = prepare(options[:global_config])
        # Support for strings without '{}' was introduced, so just double
        # check here to ensure that we pass in values surrounded by '{}'.
        if !decoded.start_with?('{')
          decoded = "{#{decoded}}"
        end
        global_config = settings_string_to_map(decoded)
        config['CONFIG'].deeper_merge!(global_config)
      end

      # Munge non-string scalar values into proper data types
      unstringify_values!(config)

      return config
    end

    def get_host_roles(node_info)
      roles = []

      node_info['roles'].each_char do |c|
        roles << ROLES[c]
      end

      node_info['arbitrary_roles'].each do |role|
        roles << role
      end

      return roles
    end

    private

    def generate_host_roles!(host_config, node_info, options)
      if not options[:disable_default_role]
        host_config['roles'] = ['agent']
      else
        host_config['roles'] = []
      end

      host_config['roles'].concat get_host_roles(node_info)
      host_config['roles'].uniq!

      if not options[:disable_role_config]
        host_config['roles'].each do |role|
          host_config.deeper_merge! get_role_config(role)
        end
      end
    end

    # Passes over all the values of config['HOSTS'] and config['CONFIG'] and
    # subsequent arrays to convert numbers or booleans into proper integer
    # or boolean types.
    def unstringify_values!(config)
      config['HOSTS'].each do |host, settings|
        settings.each do |k, v|
          config['HOSTS'][host][k] = unstringify_value(v)
        end
      end
      config['CONFIG'].each do |k, v|
        config['CONFIG'][k] = unstringify_value(v)
      end
    end

    # Attempts to convert numeric strings and boolean strings into proper
    # integer and boolean types. If value is an array, it will recurse
    # through those values.
    # Returns the input value if it's not a number string or boolean string.
    # For example "123" would be converted to 123, and "true"/"false" would be
    # converted to true/false.
    # The only valid boolean-strings are "true" and "false".
    def unstringify_value(value)
      result = Integer(value) rescue value
      if value == 'true'
        result = true
      elsif value == 'false'
        result = false
      elsif value.kind_of?(Array)
        value.each_with_index do |v, i|
          result[i] = unstringify_value(v)
        end
      end
      result
    end
  end
end
