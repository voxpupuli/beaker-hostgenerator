source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

if File.exist? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

group :release do
  gem 'github_changelog_generator', :require => false
end

group :coverage, optional: ENV['COVERAGE'] != 'yes' do
  gem 'simplecov-console', :require => false
  gem 'codecov', :require => false
end

group :rubocop do
  gem 'rubocop', '~> 1.48.1'
  gem 'rubocop-minitest', '~> 0.29.0'
  gem 'rubocop-performance', '~> 1.16.0'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-rspec', '~> 2.19.0'
end
