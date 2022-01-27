source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

if File.exist? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

group :release do
  gem 'github_changelog_generator', :require => false
end

group :coverage, optional: ENV['COVERAGE']!='yes' do
  gem 'simplecov-console', :require => false
  gem 'codecov', :require => false
end
