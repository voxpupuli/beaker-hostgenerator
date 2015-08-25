# Beaker-Template Acceptance Testing

This doc is to help you get familiar with acceptance testing you Beaker library!

## Setup

You'll need to `bundle install` in this directory in order to get acceptance testing dependencies
from the local Gemfile.

## Running

Once you've done that, you should be able to run `bundle exec rake` to see the acceptance tests run under their default settings.  

Note that in the current template, there are no pre-suites.  If you'd like to use a particular pre-suite,
then just add it here in a new `pre_suites` folder, and run the Beaker command or create a new rake task for this.

