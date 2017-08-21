require 'beaker-hostgenerator/generator'
require 'beaker-hostgenerator/hypervisor'
require 'beaker-hostgenerator/roles'
require 'beaker-hostgenerator/version'
require 'beaker-hostgenerator/abs_support'
require 'optparse'
require 'yaml'

module BeakerHostGenerator
  class CLI
    include BeakerHostGenerator::Data

    attr_reader :options

    def initialize(argv = ARGV.dup)
      @options = {
        list_platforms_and_roles: false,
        disable_default_role: false,
        disable_role_config: false,
        osinfo_version: 0,
        hypervisor: 'vmpooler',
      }

      argv.push('--help') if argv.empty?

      optparse = OptionParser.new do |opts|
        opts.banner = <<-eos
Usage: beaker-hostgenerator [options] <layout>

 where <layout> takes the following form:
  <platform>-<arch>[[<arbitrary-roles>,[...]].]<roles>[{<arbitrary-settings>,[...]}][-<arch>[[<arbitrary-roles>,[...]].]<roles>[{<arbitrary-settings>,[...]}]][-<layout>]

 examples:
  centos6-64mdca-32a
   1 CentOS 6 64 bit node with roles = master, database, agent, dashboard
   1 CentOS 6 32 bit node with roles = agent

  debian8-64m-32ad-32ac-centos6-64a
   1 Debian 8 64 bit node with roles = master
   1 Debian 8 32 bit node with roles = agent, database
   1 Debian 8 32 bit node with roles = agent, dashboard
   1 CentOS 6 64 bit node with roles = agent

  debian8-64m-windows8-64a
   1 Debian 8 64 bit node with roles = master
   1 Windows 8 64 bit node with roles = agent

 example with arbitrary roles:
  centos6-32compile_master,another_role.ma
   1 CentOS 6 32 bit node with roles = master, agent, compile_master, another_role

 example with arbitrary host settings:
  centos6-64m{hypervisor=none\\,hostname=static1\\,my-key=my-value}-32a
   1 CentOS 6 64 bit node with roles = master, hypervisor = none, node name = static1, and my-key = my-value
   1 CentOS 6 32 bit node with roles = agent and the default hypervisor

 example of a list within arbitrary host settings:
  centos6-64m{hostname=static1\\,disks=[8,16],my-list=[my-value1]}-32a
   1 CentOS 6 64 bit node with roles = master, node name = static1 and lists:
      disks:
         - 8
         - 16
       my-list:
         - my-value1
   1 CentOS 6 32 bit node with roles = agent and the default hypervisor

 Generally, it is expected that beaker-hostgenerator output will be redirected to a file, for example:
  beaker-hostgenerator centos6-64ma > host.cfg

 This can then be used in a Beaker call instead of a static Beaker config.

            eos

        opts.on('-l',
                '--list',
                'List beaker-hostgenerator supported platforms, roles, and hypervisors. ' <<
                'Does not produce host config.') do
          @options[:list_supported_values] = true
        end

        opts.on('--templates-only',
               'Generate a reduced output including only the templates from each host.') do
          @options[:templates_only] = true
        end

        opts.on('-t',
                '--hypervisor HYPERVISOR',
                'Set beaker-hostgenerator default hypervisor. ') do |h|
          @options[:hypervisor] = h
        end

        opts.on('--pe_upgrade_dir UPGRADE_PATH',
                'Explicitly set pe_upgrade_dir attribute on generated hosts. ') do |p|
          @options[:pe_upgrade_dir] = p
        end

        opts.on('--pe_upgrade_ver UPGRADE_VERSION',
                'Explicitly set pe_upgrade_ver attribute on generated hosts. ') do |p|
          @options[:pe_upgrade_ver] = p
        end

        opts.on('--pe_dir PATH',
                'Explicitly set pe_dir attribute on generated hosts. ') do |p|
          @options[:pe_dir] = p
        end

        opts.on('--pe_ver VERSION',
                'Explicitly set pe_ver attribute on generated hosts. ') do |p|
          @options[:pe_ver] = p
        end

        opts.on('--disable-role-config',
                "Do not include role-specific configuration.") do
          @options[:disable_role_config] = true
        end

        opts.on('--disable-default-role',
                "Do not include the default 'agent' role.") do
          @options[:disable_default_role] = true
        end

        opts.on('--osinfo-version MAJOR_VERSION',
                "Use OSINFO for specified beaker-hostgenerator version. " <<
                "Allows early access to future version of OSINFO data structure " <<
                "used to generate host configs.") do |version|
          version = version.to_i
          if not [0, 1].include? version
              raise "Invalid beaker-hostgenerator version: #{version}"
          end

          @options[:osinfo_version] = version
        end

        opts.on('--global-config KEYVALUE_STRING',
                "General configuration settings to be included as-is in the " <<
                "CONFIG section. Value should be in the form '{key=value,...}'.") do |p|
          @options[:global_config] = p
        end

        opts.on('-h',
                '--help',
                'Display command help.') do
          @options[:help] = opts.to_s
        end

        opts.on('-v',
                '--version',
                'Display beaker-hostgenerator version number.') do
          @options[:version] = true
        end
      end

      optparse.parse!(argv)
      @layout = argv[0]
    end

    def execute
      if @options[:help]
        @options[:help] # Value is help text string
      elsif @options[:version]
        BeakerHostGenerator::Version::STRING
      elsif @options[:list_supported_values]
        supported_values_help_text
      elsif @options[:templates_only]
        require 'json'
        config = BeakerHostGenerator::Generator.new.generate(@layout, @options)
        templates = BeakerHostGenerator::AbsSupport.extract_templates(config)
        templates.to_json
      else
        config = BeakerHostGenerator::Generator.new.generate(@layout, @options)
        config.to_yaml
      end
    end

    def execute!
      puts execute
    end

    private

    # Builds help text with a human-readable listing of all supported values
    # for the following: platforms, architectures, roles, and hypervisors.
    def supported_values_help_text
      result = "valid beaker-hostgenerator platforms:\n"
      platforms = get_platforms(@options[:osinfo_version])
      platforms.each do |k|
        result << "   #{k}\n"
      end
      result << "\n\n"

      result << "valid beaker-hostgenerator architectures:\n"
      result << "   32    => 32-bit OS\n"
      result << "   64    => 64-bit OS\n"
      result << "   6432  => 64-bit OS with 32-bit Puppet (Windows Only)\n"
      result << "   POWER => power or powerpc OS (AIX, Huawei, Redhat, SLES and Ubuntu only)\n"
      result << "   SPARC => sparc OS (Solaris only)\n"
      result << "   S390X => s390x OS (RedHat and SLES only)\n"
      result << "\n\n"

      result << "built-in beaker-hostgenerator host roles:\n"
      BeakerHostGenerator::Roles::ROLES.each do |k,v|
        result << "   #{k} => #{v}\n"
      end
      result << "\n\n"

      result << "built-in beaker-hostgenerator hypervisors:\n"
      BeakerHostGenerator::Hypervisor.builtin_hypervisors().keys.each do |k|
        result << "   #{k}\n"
      end

      result
    end
  end
end
