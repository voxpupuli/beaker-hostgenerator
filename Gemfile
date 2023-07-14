source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

eval(File.read("#{__FILE__}.local"), binding) if File.exist? "#{__FILE__}.local"

group :release do
  gem 'faraday-retry', require: false
  gem 'github_changelog_generator', require: false
end

group :coverage, optional: ENV['COVERAGE'] != 'yes' do
  gem 'codecov', require: false
  gem 'simplecov-console', require: false
end

group :rubocop do
  gem 'voxpupuli-rubocop', '~> 2.0'
end
