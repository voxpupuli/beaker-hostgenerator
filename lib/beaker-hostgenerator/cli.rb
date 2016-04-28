require 'beaker-hostgenerator/generator'
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
  <platform>-<arch><roles>[[-<platform>]-<arch>[[<arbitrary-roles>,[...]].]<roles>[...]]

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

 Generally, it is expected that beaker-hostgenerator output will be redirected to a file, for example:
  beaker-hostgenerator centos6-64ma > host.cfg

 This can then be used in a Beaker call instead of a static Beaker config.

            eos

        opts.on('-l',
                '--list',
                'List beaker-hostgenerator supported platforms and roles. ' <<
                'Does not produce host config.') do
          @options[:list_platforms_and_roles] = true
        end

        opts.on('-t',
                '--hypervisor HYPERVISOR',
                'Set beaker-hostgenerator hypervisor. ') do |h|
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
                "Do not include the default /'agent/' role.") do
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
          puts opts
          exit
        end
      end

      optparse.parse!(argv)

      if @options[:list_platforms_and_roles]
        print_platforms_and_roles
        raise BeakerHostGenerator::Exceptions::SafeEarlyExit
      else
        # Tokenizing the config definition for great justice
        @tokens = __tokenize_input(argv[0])

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
    end

    # Breaks apart the host input string into chunks suitable for processing
    # by the generator. Returns an array of substrings of the input spec string.
    #
    # The input string is expected to be properly formatted using the dash `-`
    # character as a delimiter. Dashes may also be used within braces `{...}`,
    # which are used to define arbitrary key-values on a node.
    #
    # @param spec [String] Well-formatted string specification of the hosts to
    #                      generate. For example `"centos6-64m-debian8-32a"`.
    # @returns [Array<String>] Input string split into substrings suitable for
    #                          processing by the generator. For example
    #                          `["centos6", "64m", "debian8", "32a"]`.
    def __tokenize_input(spec)
      # Here we allow dashes in certain parts of the spec string
      # i.e. "centos6-64m{hostname=foo-bar}-debian8-32"
      # by first replacing all occurrences of - with | that exist within
      # the braces {...}.
      #
      # So we'd end up with:
      #   "centos6-64m{hostname=foo|bar}-debian8-32"
      #
      # Which we can then simply split on - into:
      #   ["centos6", "64{hostname=foo|bar}", "debian8", "32"]
      #
      # And then finally turn the | back into - now that we've
      # properly decomposed the spec string:
      #   ["centos6", "64{hostname=foo-bar}", "debian8", "32"]
      #
      # NOTE we've specifically chosen to use the pipe character |
      # due to its unlikely occurrence in the user input string.
      spec = String.new(spec) # Copy so we can replace characters inline
      within_braces = false
      spec.chars.each_with_index do |char, index|
        case char
        when '{'
          within_braces = true
        when '}'
          within_braces = false
        when '-'
          spec[index] = '|' if within_braces
        end
      end
      tokens = spec.split('-')
      tokens.map { |t| t.gsub('|', '-') }
    end

    def print_platforms_and_roles
      puts "valid beaker-hostgenerator platforms:  "
      platforms = get_platforms(@options[:osinfo_version])
      platforms.each do |k|
        puts "   #{k}"
      end

      puts "\n"

      puts "valid beaker-hostgenerator architectures:"
      puts "   32   => 32-bit OS"
      puts "   64   => 64-bit OS"
      puts "   6432 => 64-bit OS with 32-bit Puppet (Windows Only)"
      puts "\n"

      puts "valid beaker-hostgenerator host roles:  "
      ROLES.each do |k,v|
        puts "   #{k} => #{v}"
      end
    end

    def execute
      BeakerHostGenerator::Generator.new.generate(@tokens, @options)
    end

    def execute!
      puts execute
    end
  end
end
