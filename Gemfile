source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

eval(File.read("#{__FILE__}.local"), binding) if File.exist? "#{__FILE__}.local"

group :release, optional: true do
  gem 'faraday-retry', require: false
  gem 'github_changelog_generator', require: false
end
