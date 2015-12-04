require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/data/vmpooler'
require 'deep_merge'

module BeakerHostGenerator
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
