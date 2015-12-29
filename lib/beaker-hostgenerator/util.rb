require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/data/vmpooler'
require 'deep_merge'

module BeakerHostGenerator
  module Utils
    include BeakerHostGenerator::Data
    include BeakerHostGenerator::Data::Vmpooler

    def pe_dir(version, family)
      # If our version is the same as our family, we're installing a
      # released version. Use the archive path. Otherwise, we want to use
      # the development build path.
      if version && family
        if version == family
          return "http://enterprise.delivery.puppetlabs.net/archives/releases/#{family}/"
        else
          return "http://enterprise.delivery.puppetlabs.net/#{family}/ci-ready"
        end
      end
    end

    def fixup_node(cfg)
      # PE 2.8 doesn't exist for EL 4. We use 2.0 instead.
      if cfg['platform'] =~ /el-4/ and PE_VERSION =~ /2\.8/
        cfg['pe_ver'] = "2.0.3"
      end
    end

    def dump_hosts(hosts, path)
      config = {}
      config.deep_merge! BASE_CONFIG
      config.deep_merge! VMPOOLER_CONFIG

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

    def get_platforms(hypervisor_type='vmpooler', version=0)
      case hypervisor_type
      when /vmpooler/
        osinfo = BeakerHostGenerator::Data::Vmpooler.get_osinfo()
      else
        raise "Invalid hypervisor #{hypervisor_type}"
      end
      return osinfo
    end

    def get_roles
      return BeakerHostGenerator::Data::ROLES
    end

    module_function :dump_hosts, :get_platforms, :get_roles, :pe_dir
  end
end
