source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

eval(File.read("#{__FILE__}.local"), binding) if File.exist? "#{__FILE__}.local"

group :release do
  gem 'github_changelog_generator', require: false
end

group :coverage, optional: ENV['COVERAGE'] != 'yes' do
  gem 'codecov', require: false
  gem 'simplecov-console', require: false
end

group :rubocop do
  gem 'rubocop', '~> 1.50.2'
  gem 'rubocop-minitest', '~> 0.30.0'
  gem 'rubocop-performance', '~> 1.17.1'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-rspec', '~> 2.20.0'
end
