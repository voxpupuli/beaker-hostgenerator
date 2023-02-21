# frozen_string_literal: true

begin
  require 'simplecov'
  require 'simplecov-console'
  require 'codecov'
rescue LoadError
else
  SimpleCov.start do
    track_files 'lib/**/*.rb'

    add_filter '/spec'

    enable_coverage :branch

    # do not track vendored files
    add_filter '/vendor'
    add_filter '/.vendor'
  end

  SimpleCov.formatters = [
    SimpleCov::Formatter::Console,
    SimpleCov::Formatter::Codecov,
  ]
end

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
