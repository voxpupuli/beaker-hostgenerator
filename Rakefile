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



namespace :ci do

  namespace :test do

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


task :default => :test
