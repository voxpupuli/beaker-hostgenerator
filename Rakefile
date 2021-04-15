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

begin
  require 'github_changelog_generator/task'
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.header = "# Changelog\n\nAll notable changes to this project will be documented in this file."
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix modulesync skip-changelog]
    config.user = 'voxpupuli'
    config.project = 'beaker-hostgenerator'
    config.future_release = Gem::Specification.load("#{config.project}.gemspec").version
  end

  # Workaround for https://github.com/github-changelog-generator/github-changelog-generator/issues/715
  require 'rbconfig'
  if RbConfig::CONFIG['host_os'] =~ /linux/
    task :changelog do
      puts 'Fixing line endings...'
      changelog_file = File.join(__dir__, 'CHANGELOG.md')
      changelog_txt = File.read(changelog_file)
      new_contents = changelog_txt.gsub(/\r\n/, "\n")
      File.open(changelog_file, 'w') { |file| file.puts new_contents }
    end
  end
rescue LoadError
end
