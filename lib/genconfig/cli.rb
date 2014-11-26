require 'genconfig/generator'

module GenConfig
  class CLI
    include GenConfig::Data

    def initialize
      # Tokenizing the config definition for great justice
      @tokens = ARGV[0].split('-')
      @hypervisor = ARGV[1] || 'vsphere'
    end

    def execute!
      generator = GenConfig::Generator.create @hypervisor
      yaml_string = generator.generate @tokens
      puts yaml_string
    end
  end
end
