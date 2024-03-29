require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/roles'
require 'beaker-hostgenerator/hypervisor/vmpooler'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Utils
    module_function

    def pe_dir(version, _family = nil)
      BeakerHostGenerator::Data.pe_dir(version)
    end

    def dump_hosts(hosts, path)
      vmpooler_hypervisor = BeakerHostGenerator::Hypervisor::Vmpooler.new
      config = {}
      config.deeper_merge! BeakerHostGenerator::Data.BASE_CONFIG
      config['CONFIG'].deeper_merge! vmpooler_hypervisor.global_config

      hosts.each do |host|
        config['HOSTS'][host.node_name] = {
          'roles' => host['roles'],
          'hypervisor' => "#{host['hypervisor']}",
          'platform' => "#{host['platform']}",
        }
      end

      File.write(path, config.to_yaml)
    end

    def get_platforms(_hypervisor_type = 'vmpooler', bhg_version = 0)
      BeakerHostGenerator::Data.get_platforms(bhg_version)
    end

    def get_roles
      BeakerHostGenerator::Roles.ROLES
    end
  end
end
