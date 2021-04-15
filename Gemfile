source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

group :release do
  gem 'github_changelog_generator', :require => false
end
