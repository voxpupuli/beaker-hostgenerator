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
    end

    desc "Run spec tests with coverage"
    RSpec::Core::RakeTask.new(:coverage) do |t|
      ENV['BEAKER_TEMPLATE_COVERAGE'] = 'y'
      t.rspec_opts = ['--color']
      t.pattern = 'spec/'
    end

  end

  namespace :acceptance do

    desc <<-EOS
A quick acceptance test, named because it has no pre-suites to run
    EOS
    task :quick do

      sh("beaker",
         "--hosts", ENV['CONFIG'] || "acceptance/config/nodes/vagrant-ubuntu-1404.yml",
         "--tests", "acceptance/tests",
         "--log-level", "debug",
         "--keyfile", ENV['KEY'] || "#{ENV['HOME']}/.ssh/id_rsa")
    end

  end

end

# namespace-named default tasks.
# these are the default tasks invoked when only the namespace is referenced.
# they're needed because `task :default` in those blocks doesn't work as expected.
task 'test:spec' => ['test:spec:run', 'test:spec:minitest']
task 'test:acceptance' => 'test:acceptance:quick'

# global defaults
task :test => 'test:spec'
task :default => :test
