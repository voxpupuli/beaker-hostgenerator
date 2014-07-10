require 'genconfig/generator'
require 'genconfig/data/vsphere'
require 'genconfig/data'

module GenConfig
  class VSphere < GenConfig::Generator
    include GenConfig::Data
    include GenConfig::Data::VSphere

    def initialize config
      @config = config
      @config.merge! BASE_CONFIG
      @config.merge! VSPHERE_CONFIG
    end

    def generate_node node_info
      # Template for a single node.
      host_config = {
        'roles' => ['agent'],
        'hypervisor' => 'vcloud',
        'pe_dir' => pe_dir(PE_VERSION, PE_FAMILY),
        'pe_ver' => PE_VERSION,
        'pe_upgrade_dir' => pe_dir(PE_UPGRADE_VERSION, PE_UPGRADE_FAMILY),
        'pe_upgrade_ver' => PE_UPGRADE_VERSION,
      }

      ostype = node_info['ostype']
      nodeid = node_info['nodeid']
      bits = node_info['bits']
      roles = node_info['roles']

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

  end
end
