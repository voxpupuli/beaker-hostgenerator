source ENV['GEM_SOURCE'] || "https://rubygems.org"

gemspec

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
