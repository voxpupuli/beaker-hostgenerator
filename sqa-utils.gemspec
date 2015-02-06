Gem::Specification.new do |s|
  s.name        = "sqa-utils"
  s.version     = " 0.11.4"
  s.date        = "2015-02-01"
  s.summary     = "SQA Utilities"
  s.description = "Utilities we use to help test things here at Puppet"
  s.authors     = ["Branan Purvine-Riley", "Wayne Warren"]
  s.email       = ["qe-team@puppetlabs.com"]
  s.license     = 'Apache'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Run time dependencies
  s.add_runtime_dependency 'deep_merge', '~> 1.0'
  s.add_runtime_dependency 'json', '~> 1.8'

end
