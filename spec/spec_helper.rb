# frozen_string_literal: true

# The Rakefile includes this, but having them in spec_helper makes it possible
# to run specific test cases via commandline when developing.
local_libdir = File.join(__FILE__, '../../lib')
local_testdir = File.join(__FILE__, '../../test')
$LOAD_PATH.unshift(local_libdir) unless $LOAD_PATH.include?(local_libdir)
$LOAD_PATH.unshift(local_testdir) unless $LOAD_PATH.include?(local_testdir)

require 'beaker-hostgenerator'
require 'helpers'

require 'rspec/its'

RSpec.configure do |config|
  config.include TestFileHelpers
  config.include HostHelpers
end
