require 'open3'

task :default => [ 'test:spec' ]

task :test do
  Rake::Task['test:spec'].invoke
end

namespace :test do
  desc 'Run specs and check for deprecation warnings'
  task :spec do
    original_dir = Dir.pwd
    Dir.chdir( File.expand_path(File.dirname(__FILE__)) )
    exit_status = 1
    output = ''
    Open3.popen3("bundle exec rspec") {|stdin, stdout, stderr, wait_thr|
      while line = stdout.gets
        puts line
      end
      output = stdout
      if not wait_thr.value.success?
        fail "Failed to 'bundle exec rspec' (exit status: #{wait_thr.value})"
      end
      exit_status = wait_thr.value
    }
    if exit_status != /0/
      #check for deprecation warnings
      if output =~ /Deprecation Warnings/
        fail "DEPRECATION WARNINGS in spec generation, please fix!"
      end
    end
    Dir.chdir( original_dir )
  end
end
