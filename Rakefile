require 'rspec/core/rake_task'
require 'rake/testtask'

namespace :test do

  namespace :spec do

    task :minitest do
      desc "Run minitest tests"
      Rake::TestTask.new do |task|
        task.libs << %w(test lib)
        task.test_files = FileList['test/test*.rb']
        task.verbose = true
      end
    end

    desc "Run spec tests"
    RSpec::Core::RakeTask.new(:run) do |t|
      t.rspec_opts = ['--color']
      t.pattern = 'spec/'
      t.ruby_opts = '-Itest'
    end

    desc "Run spec tests with coverage"
    RSpec::Core::RakeTask.new(:coverage) do |t|
      ENV['BEAKER_TEMPLATE_COVERAGE'] = 'y'
      t.rspec_opts = ['--color']
      t.pattern = 'spec/'
    end

  end

end

namespace :generate do
  desc "Generate test fixtures."
  task :fixtures do
    $LOAD_PATH.unshift(
      File.join(Dir.pwd, 'lib'),
      File.join(Dir.pwd, 'test')
    )
    require 'beaker-hostgenerator'
    require 'util/generator_helpers'

    fixgen = FixtureGenerator.new
    fixgen.generate
  end
end

# namespace-named default tasks.
# these are the default tasks invoked when only the namespace is referenced.
# they're needed because `task :default` in those blocks doesn't work as expected.
task 'test:spec' => ['test:spec:run', 'test:spec:minitest']

# global defaults
task :test => 'test:spec'
task :default => :test
