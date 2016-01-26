require 'beaker-hostgenerator/util'
require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/error'
require 'beaker-hostgenerator/roles'

require 'yaml'

module BeakerHostGenerator
  class Generator
    include BeakerHostGenerator::Data
    include BeakerHostGenerator::Errors
    include BeakerHostGenerator::Utils

    BASE_HOST_CONFIG = {
      'pe_dir' => BeakerHostGenerator::Utils.pe_dir(PE_VERSION, PE_FAMILY),
      'pe_ver' => PE_VERSION,
      'pe_upgrade_dir' => BeakerHostGenerator::Utils.pe_dir(PE_UPGRADE_VERSION, PE_UPGRADE_FAMILY),
      'pe_upgrade_ver' => PE_UPGRADE_VERSION,
    }
    attr_reader :options

    def initialize options
      @options = options
    end

    def self.create( options )
      hypervisor_type = options[:hypervisor]

      hclass = case hypervisor_type
               when /vmpooler/
                 BeakerHostGenerator::Vmpooler
               when /vagrant/
                 BeakerHostGenerator::Vagrant
               else
                 raise "Invalid hypervisor #{type}"
               end

      return hclass.new(options)
    end

    def generate tokens
      nodeid = Hash.new(1)
      ostype = nil

      tokens.each do |token|
        if is_ostype_token?(token, @options[:osinfo_version])
          if nodeid[ostype] == 1 and ostype != nil
            raise "Error: no nodes generated for #{ostype}"
          end
          ostype = token
          next
        end

        node_info = __parse_node_info_token(token)

        node_info['ostype'] = ostype
        node_info['nodeid'] = nodeid[ostype]

        config = BASE_HOST_CONFIG

        [:pe_dir, :pe_ver, :pe_upgrade_dir, :pe_upgrade_ver].each do |option|
          if option
            config[option.to_s] = @options[option]
          end
        end

        host_name, host_config = generate_node(
          node_info, BASE_HOST_CONFIG, bhg_version=@options[:osinfo_version])

        if PE_USE_WIN32 && ostype =~ /windows/ && node_info['bits'] == "64"
          host_config['ruby_arch'] = 'x86'
          host_config['install_32'] = true
        end

        if not @options[:disable_default_role]
          host_config['roles'] = ['agent']
        else
          host_config['roles'] = []
        end

        host_config['roles'].concat __generate_host_roles(node_info)
        host_config['roles'].uniq!

        if not @options[:disable_role_config]
          host_config['roles'].each do |role|
            host_config.deep_merge! __get_role_config(role)
          end
        end

        @config['HOSTS'][host_name] = host_config
        nodeid[ostype] += 1
      end

      return @config.to_yaml
    end

    def __get_role_config role
      begin
        r = BeakerHostGenerator::Roles.new
        m = r.method(role)
      rescue NameError
        return {}
      end

      return m.call
    end

    def __parse_node_info_token token
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

    def __generate_host_roles node_info
      roles = []

      node_info['roles'].each_char do |c|
        roles << ROLES[c]
      end

      node_info['arbitrary_roles'].each do |role|
        roles << role
      end

      return roles
    end

    def is_ostype_token?
      raise "Method 'is_ostype_token?' not implemented!"
    end

    def generate_node
      raise "Method 'generate_node' not implemented!"
    end

  end
end

require 'beaker-hostgenerator/generator/vmpooler'
