$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'beaker-hostgenerator/version'

Gem::Specification.new do |s|
  s.name        = "beaker-hostgenerator"
  s.version     = BeakerHostGenerator::Version::STRING
  s.authors     = ["Branan Purvine-Riley", "Wayne Warren", "Nate Wolfe", "Vox Pupuli"]
  s.email       = ["pmc@voxpupuli.org"]
  s.homepage    = "https://github.com/puppetlabs/beaker-hostgenerator"
  s.summary     = "Beaker Host Generator Utility"
  s.description = <<~eos
    The beaker-hostgenerator tool will take a Beaker SUT (System Under Test) spec as
    its first positional argument and use that to generate a Beaker host
    configuration file.
  eos
  s.license = 'Apache2'

  s.files         = `git ls-files`.split("\n").reject { |f| f.match(/^(test|spec)/) }
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = Gem::Requirement.new('>= 2.7')

  # Testing dependencies
  s.add_development_dependency 'fakefs', '>= 0.6', '< 3.0'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its'

  # Documentation dependencies
  s.add_development_dependency 'thin'
  s.add_development_dependency 'yard'

  # Run time dependencies
  s.add_runtime_dependency 'deep_merge', '~> 1.0'
end
