# beaker-template

Let's construct a Beaker DSL extension library!

# Why Would We Do Such a Thing?

There are two reasons to create a Beaker library:

1. To pull functionality out of Beaker core to be maintained/improved separately (mostly QE tasks)
2. To provide additional methods to the Beaker DSL, extending Beaker functionality (biggest Beaker user use case)

These instructions are here to give people a working guide on how to create your own Beaker
libraries for the second use case. If you'd like to pull functionality out of Beaker
(the first use case), then please create a 
[Beaker JIRA](https://tickets.puppetlabs.com/browse/BKR)
ticket for it, and we can discuss that there.


# Beaker Library Creation Process Overview

This section covers the high-level process of creating a Beaker library.
If you'd like to know more about a particular step, checkout its section below.

1. Clone this repo (beaker-template)
2. Rename the library
3. Create spec tests
4. Create acceptance tests
5. Publish your library!

# Step Details

## 1. Clone this repo (beaker-template)

No hidden tricks. Just do it, people!

## 2. Rename the library

There are a number of steps required to make sure your library is namespaced & setup correctly:

### A. File structure changes

The accepted naming pattern for Beaker libraries follows from 'beaker-template',
where you change `template` to match the name of the library you're creating. Some
examples would be `beaker-hiera`, `beaker-facter`, `beaker-puppet`, etc.


Once you've chosen your library name, you'll have to change a number of files to
match it. The main project folder, and the corresponding folder under `lib` will
both have to be renamed.


The `beaker-template.rb` file under what was `lib/beaker-template` will have to
be changed to match this new name as well.

### B. Code changes
  
The template provides you with the default module path `Beaker::DSL::Helpers::Template`.
This path follows from the DSL pattern within Beaker, and `Beaker::DSL::Helpers`
should stay at the front of your path. `Template` should be changed to the name
of your project. This change will be needed in a number of places, and doing a
general search-and-destroy for the word `Template` should cover it.


`require` references will need to be updated as well.  Searching and replacing
all lines that include: 

    require 'beaker-template
    
should cover all uses of this.

### C. Gemspec changes 

The gemspec file has a few additional changes that will be required.


It includes both the require and module path changes as well.


A general audit of every line of the `beaker-template.gemspec` file should be done,
which should include renaming it to the name of the project, and changing most,
if not all, of the lines in the first block describing the library itself.

## 3. Create spec tests

Spec tests all live under the `spec` folder.  These are the default rake task, &
so can be run with a simple `bundle exec rake`, as well as being fully specified
by running `bundle exec rake test:spec:run` or using the `test:spec` task.


There are also code coverage tests built into the template, which can be run
with spec testing by running the `test:spec:coverage` rake task.


These will fail by default.  This is on purpose, as some test refactoring (and
hopefully test addition) should be done prior to wanting to release a library.
Please add more spec tests either in what started as `spec/beaker-template/helpers_spec.rb`,
or create more spec testing files under `spec/beaker-template`, and they'll be 
included in spec testing automatically.

## 4. Create acceptance tests

Acceptance tests live in the `acceptance/tests` folder.  These are Beaker tests,
& are dependent on having Beaker installed. Note that this will happen with a
`bundle install` execution, but can be avoided if you're not looking to run 
acceptance tests by ignoring the `acceptance_testing` gem group.


You can run the acceptance testing suite by invoking the `test:acceptance` rake
task. It should be noted that this is a shortcut for the `test:acceptance:quick`
task, which is named as such because it uses no pre-suite.  This uses a default
provided hosts file for acceptance under the `acceptance/config` directory. If
you'd like to provide your own hosts file, set the `CONFIG` environment variable.


Acceptance tests will also fail by default, for the same reason given above as
spec tests.

## 5. Publish your library!

_But wait_, you might be thinking, _what about developing the functionality?_
Sure, we expect that to happen before this step. But, we're figuring that naming
it in an explicit step would get us into a debate over TDD, or just the relative
positioning of development in general. Let's just say that you've gotten over 
that part at some point in the recent past.


To publish your library as an official Beaker library, open a
[Beaker JIRA ticket](https://tickets.puppetlabs.com/browse/BKR) to do so, and we
can talk about setting up the Jenkins jobs to get this testing & released as an
Official Beaker Library Gem!

## 6. Profit!
