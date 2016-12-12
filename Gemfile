source ENV['GEM_SOURCE'] || "https://rubygems.org"

gemspec


group :testing do
  gem "minitest"
end


if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
