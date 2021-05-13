require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/roles'
require 'beaker-hostgenerator/hypervisor/vmpooler'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Utils
    module_function

    def pe_dir(version, family = nil)
      BeakerHostGenerator::Data.pe_dir(version)
    end

    def fixup_node(cfg)
      BeakerHostGenerator::Data.fixup_node(cfg)
    end

    def dump_hosts(hosts, path)
      vmpooler_hypervisor = BeakerHostGenerator::Hypervisor::Vmpooler.new
      config = {}
      config.deeper_merge! BeakerHostGenerator::Data.BASE_CONFIG
      config['CONFIG'].deeper_merge! vmpooler_hypervisor.global_config()

      hosts.each do |host|
        config['HOSTS'][host.node_name] = {
          'roles' => host['roles'],
          'hypervisor' => "#{host['hypervisor']}",
          'platform' => "#{host['platform']}",
        }
      end

      File.open(path, 'w') do |file|
        file.write(config.to_yaml)
      end
    end

    def get_platforms(hypervisor_type='vmpooler', bhg_version=0)
      BeakerHostGenerator::Data.get_platforms(bhg_version)
    end

    def get_roles
      BeakerHostGenerator::Roles.ROLES
    end
  end
end
