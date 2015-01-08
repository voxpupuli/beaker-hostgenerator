Gem::Specification.new do |s|
  s.name        = "sqa-utils"
  s.version     = " 0.10.0"
  s.date        = "2013-12-27"
  s.summary     = "SQA Utilities"
  s.description = "Utilities we use to help test things here at Puppet"
  s.authors     = ["Branan Purvine-Riley"]
  s.email       = ["sqa@puppetlabs.com"]
  s.executables = ["genconfig", "genconfig2"]
  s.license     = 'Apache'

  s.require_paths = ["lib"]

  # Run time dependencies
  s.add_runtime_dependency 'deep_merge'
  s.add_runtime_dependency 'json', '1.8'

end
