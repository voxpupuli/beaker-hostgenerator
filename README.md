# Overview

This is a library of scripts that are useful for developers, testers,
and CI maintainers in getting things done with testing our software.

# Building an Update

Pushing out an update is super easy!

Note that you need rubygems >= 2.1.7, and the stickler gem installed
in order to push. If you are using rvm, it is generally safe to run `gem update --system`.

1. Bump the version in the gemspec
2. run `gem build sqa-utils.gemspec`
3. run `stickler push sqa-utils-${version}.gem --server http://rubygems.delivery.puppetlabs.net`
