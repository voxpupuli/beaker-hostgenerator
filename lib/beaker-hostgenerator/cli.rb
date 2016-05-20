require 'beaker-hostgenerator/generator'
require 'beaker-hostgenerator/hypervisor'
require 'beaker-hostgenerator/roles'
require 'beaker-hostgenerator/version'
require 'optparse'

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
      else
        print_warnings
        BeakerHostGenerator::Generator.new.generate(@layout, @options)
      end
    end

    def execute!
      puts execute
    end

    private

    def print_warnings
      if @options[:osinfo_version] === 0
        warning = <<-eow
WARNING: Starting with beaker-hostgenerator 1.x platform strings for "el" hosts
will correspond to the actual linux distribution name. ie, the platform string
corresponding to a host specified as "centos4_64a" will be "centos-4-x86_64"
rather than "el-4-x86_64". It is recommended that you update your project's test
suites ASAP or be forced to do so when beaker-hostgenerator development moves on
to the 1.x series. We don't intend to backport features or platforms to 0.x.
eow
        STDERR.puts(warning)
      end
    end

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
      result << "   32   => 32-bit OS\n"
      result << "   64   => 64-bit OS\n"
      result << "   6432 => 64-bit OS with 32-bit Puppet (Windows Only)\n"
      result << "\n\n"

      result << "valid beaker-hostgenerator host roles:\n"
      BeakerHostGenerator::Roles::ROLES.each do |k,v|
        result << "   #{k} => #{v}\n"
      end
      result << "\n\n"

      result << "valid beaker-hostgenerator hypervisors:\n"
      BeakerHostGenerator::Hypervisor.supported_hypervisors().keys.each do |k|
        result << "   #{k}\n"
      end

      result
    end
  end
end
