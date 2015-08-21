require 'rspec/core/rake_task'

desc "Run spec tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/'
end

desc "Run spec tests with coverage"
RSpec::Core::RakeTask.new(:coverage) do |t|
  ENV['BEAKER_TEMPLATE_COVERAGE'] = 'y'
  t.rspec_opts = ['--color']
  t.pattern = 'spec/'
end

task :default => :test