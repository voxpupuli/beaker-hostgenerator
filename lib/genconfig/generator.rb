require 'genconfig/util'
require 'genconfig/data'

require 'yaml'

module GenConfig

  module Generator
    include GenConfig::Data
    include GenConfig::Utils

    def generate_vsphere node
      # Template for a single node.
      host_config = {
        'roles' => ['agent'],
        'hypervisor' => 'vcloud',
        'pe_dir' => pe_dir(PE_VERSION, PE_FAMILY),
        'pe_ver' => PE_VERSION,
        'pe_upgrade_dir' => pe_dir(PE_UPGRADE_VERSION, PE_UPGRADE_FAMILY),
        'pe_upgrade_ver' => PE_UPGRADE_VERSION,
      }

      ostype = node['ostype']
      nodeid = node['nodeid']
      bits = node['bits']
      roles = node['roles']

      # node definition state

      platform = "#{ostype}-#{bits}"
      name = "#{platform}-#{nodeid}"

      host_config.merge! OSINFO[platform]

      # parse the roles out and append to the node
      roles.each_char do |c|
        host_config['roles'] << ROLES[c]
      end

      # Remove any duplicates (such as user-specified agents)
      host_config['roles'].uniq!

      # Make the template path fully qualified
      template = host_config['template']
      host_config['template'] = "#{QA_VCENTER_PATH}/#{template}"

      # Some platforms have special requirements. We munge the node
      # host_config here if that is necessary.
      fixup_node host_config

      return name, host_config
    end

    def generate tokens, hypervisor='vsphere'
      nodeid = 1
      ostype = tokens[0]
      tokens = tokens.drop(1)

      case hypervisor
      when /vsphere/
        config = deep_copy(VSPHERE_BASE_CONFIG)
      else
        fail "Unsupported hypervisor type: #{hypervisor}"
      end

      tokens.each do |toke|
        node = NODE_REGEX.match(toke)
        node = {
          'bits' => node['bits'],
          'roles' => node['roles'],
          'ostype' => ostype,
          'nodeid' => nodeid,
        }

        case hypervisor
        when /vsphere/
          host_name, host_config = generate_vsphere node
        else
          fail "Unsupported hypervisor type: #{hypervisor}"
        end
        config['HOSTS'][host_name] = host_config
        nodeid += 1
      end

      return config.to_yaml
    end
  end
end
