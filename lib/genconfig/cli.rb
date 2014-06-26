require 'genconfig/generator'

module GenConfig
  class CLI
    include GenConfig::Generator
    include GenConfig::Data

    def initialize
      @tokens = ARGV[0].split('-')
    end

    def execute!
      # Tokenizing the config definition for great justice
      yaml_string = generate @tokens
      puts yaml_string
    end
  end
end
