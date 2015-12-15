# How To Contribute To Beaker Host Generator

## Making Changes

* Create a topic branch based on `beaker-hostgenerator`'s master branch.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are in the proper format, ie

```
    (BKR-1234) Make the example in CONTRIBUTING imperative and concrete

    Without this patch applied the example commit message in the CONTRIBUTING
    document is not a concrete example.  This is a problem because the
    contributor is left to imagine what the commit message should look like
    based on a description rather than an example.  This patch fixes the
    problem by making the example concrete and imperative.

    The first line is a real life imperative statement with a ticket number
    from our issue tracker.  The body describes the behavior without the patch,
    why this is a problem, and how the patch fixes the problem when applied.
```

* Make sure you have added [RSpec](http://rspec.info/) tests that exercise your
  changes. These test should be located in the appropriate `spec/` subdirectory.
  The addition of new methods/classes or the addition of code paths to existing
  methods/classes requires additional RSpec coverage.
* Run the tests to assure nothing else was accidentally broken, using `rake test`
  * **Bonus**: if possible ensure that `rake test` runs without failures for
    additional Ruby versions (1.9, 2.0, etc). Beaker supports Ruby 1.9+, and
    breakage of support for older/newer rubies will cause a patch to be
    rejected.

## Gem Releases

Puppet Labs' QE team will determine when `beaker-hostgenerator` is ready for a
gem release. Generally speaking, we make an effort to follow the guidelines
provided by [Semantic Versioning 2.0.0](http://semver.org).

## Submitting Changes

* Sign the [Contributor License Agreement](http://links.puppetlabs.com/cla).
* Push your changes to a topic branch in your fork of the repository.
* Submit a pull request to
  [Beaker Host Generator](https://github.com/puppetlabs/beaker-hostgenerator)
* PRs are reviewed as time permits.

# Additional Resources

* [More information on contributing](http://links.puppetlabs.com/contribute-to-puppet)
* [Bug tracker (Jira)](http://tickets.puppetlabs.com)
* [BKR Jira Project](https://tickets.puppetlabs.com/issues/?jql=project%20%3D%20BKR)
* [Contributor License Agreement](http://links.puppetlabs.com/cla)
* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
