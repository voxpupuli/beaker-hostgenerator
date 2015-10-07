require 'simplecov'
require 'beaker-template'
require 'helpers'

require 'rspec/its'
require 'genconfig'

RSpec.configure do |config|
  config.include TestFileHelpers
  config.include HostHelpers
end
