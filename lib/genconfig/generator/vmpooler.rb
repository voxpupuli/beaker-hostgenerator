require 'genconfig/generator'
require 'genconfig/data/vmpooler'
require 'genconfig/data'
require 'deep_merge'

module GenConfig
  class Vmpooler < GenConfig::Generator
    include GenConfig::Data
    include GenConfig::Data::Vmpooler

    def initialize
      @config = {}
      @config.deep_merge! BASE_CONFIG
      @config.deep_merge! VMPOOLER_CONFIG
    end

    def generate_node node_info
      # Template for a single node.
      host_config = {
        'roles' => ['agent'],
        'hypervisor' => 'vmpooler',
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

      host_config.deep_merge! OSINFO[platform]

      # parse the roles out and append to the node
      roles.each_char do |c|
        host_config['roles'] << ROLES[c]
      end

      # Remove any duplicates (such as user-specified agents)
      host_config['roles'].uniq!

      # Some platforms have special requirements. We munge the node
      # host_config here if that is necessary.
      fixup_node host_config

      return name, host_config
    end

  end
end
