require 'genconfig/util'
require 'genconfig/data'

require 'yaml'

module GenConfig
  class Generator
    include GenConfig::Data
    include GenConfig::Utils

    BASE_HOST_CONFIG = {
        'roles' => ['agent'],
        'pe_dir' => GenConfig::Utils.pe_dir(PE_VERSION, PE_FAMILY),
        'pe_ver' => PE_VERSION,
        'pe_upgrade_dir' => GenConfig::Utils.pe_dir(PE_UPGRADE_VERSION, PE_UPGRADE_FAMILY),
        'pe_upgrade_ver' => PE_UPGRADE_VERSION,
      }

    def self.create( hypervisor_type )

      hclass = case hypervisor_type
      when /vmpooler/
        GenConfig::Vmpooler
      when /vagrant/
        GenConfig::Vagrant
      else
        raise "Invalid hypervisor #{type}"
      end

      return hclass.new
    end

    def generate tokens
      nodeid = 1
      ostype = nil

      tokens.each do |token|
        node_info = __parse_node_info_token(token)
        if node_info
          raise "Can't create a node without an OS" unless ostype

          node_info['ostype'] = ostype
          node_info['nodeid'] = nodeid

          host_name, host_config = generate_node(node_info, BASE_HOST_CONFIG)

          if PE_USE_WIN32 && ostype =~ /windows/ && node_info['bits'] == "64"
            host_config['install_32'] = true
          end

          host_config['roles'].concat __generate_host_roles(node_info)
          host_config['roles'].uniq!

          @config['HOSTS'][host_name] = host_config
          nodeid += 1
        else
          ostype = token
        end
      end

      return @config.to_yaml
    end

    def __parse_node_info_token token
        node_info = NODE_REGEX.match(token)

        if node_info
          node_info = Hash[ node_info.names.zip( node_info.captures ) ]
        else
          return nil
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

    def generate_node
      raise "Method 'generate_node' not implemented!"
    end

  end
end

require 'genconfig/generator/vmpooler'
