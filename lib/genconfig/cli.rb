require 'genconfig/generator'
require 'optparse'

module GenConfig
  class CLI
    include GenConfig::Data

    attr_reader :options

    def initialize
      @options = {
        list_platforms_and_roles: false,
        hypervisor: 'vmpooler',
      }

      optparse = OptionParser.new do |opts|
        opts.banner = <<-eos
Usage: genconfig2 [options] <layout>

 where <layout> takes the following form:
  <platform>-<arch><roles>[[-<platform>]-<arch><roles>[...]]

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

 Generally, it is expected that genconfig output will be redirected to a file, for example:
  genconfig2 centos6-64ma > host.cfg

 This can then be used in a Beaker call instead of a static Beaker config.

        eos

        opts.on('-l',
                '--list',
                'List genconfig2 supported platforms and roles. ' <<
                'Does not produce host config.') do
          @options[:list_platforms_and_roles] = true
        end

        opts.on('-t',
                '--hypervisor HYPERVISOR',
                'Set genconfig2 hypervisor. ') do |h|
          @options[:hypervisor] = h
        end

        opts.on('-h',
                '--help',
                'Display command help.') do
          puts opts
          exit
        end
      end

      optparse.parse!

      if @options[:list_platforms_and_roles]
        print_platforms_and_roles
        exit
      end

      # Tokenizing the config definition for great justice
      @tokens = ARGV[0].split('-')
    end

    def print_platforms_and_roles
        puts "valid genconfig platforms:  "
        osinfo = GenConfig::Utils.get_platforms
        osinfo.each do |k,v|
          puts "   #{k}"
        end

        puts "\n"

        roles = GenConfig::Utils.get_roles
        puts "valid genconfig host roles:  "
        roles.each do |k,v|
          puts "   #{k} => #{v}"
        end
    end

    def execute!
      generator = GenConfig::Generator.create @options[:hypervisor]
      yaml_string = generator.generate @tokens
      puts yaml_string
    end
  end
end
