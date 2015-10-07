require 'genconfig/data'
require 'genconfig/data/vmpooler'
require 'deep_merge'

module GenConfig
  class Roles

    def initialize
    end

    def compile_master
      return {
        'frictionless_options' => {
          'main' => {
            'dns_alt_names' => 'puppet',
            'environmentpath' => '/etc/puppetlabs/puppet/environments',
          }
        }
      }
    end
  end
end
