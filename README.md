# Beaker Host Generator

`beaker-hostgenerator` is a command line utility designed to generate beaker
host config files using a compact command line SUT specification.

It currently only supports puppetlabs' internal [vmpooler][vmpooler] templates,
but is designed in a way that makes it possible to easily add support for
additional hypervisor templates (any hypervisor type supported by
[beaker][beaker]).

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Beaker Host Generator](#beaker-host-generator)
    - [Usage](#usage)
        - [Simple two-host SUT layout](#simple-two-host-sut-layout)
        - [Single-host SUT layout with Arbitrary Roles](#single-host-sut-layout-with-arbitrary-roles)
    - [Testing](#testing)
        - [Test Fixtures](#test-fixtures)
            - [Generated Fixtures](#generated-fixtures)
    - [Support](#support)
    - [License](#license)

<!-- markdown-toc end -->
 
## Usage

Below are some example usages of `beaker-hostgenerator`.

### Simple two-host SUT layout

```
$ beaker-hostgenerator centos6-64mdca-32a
```

Will generate

```yaml
---
HOSTS:
  centos6-64-1:
    pe_dir:
    pe_ver:
    pe_upgrade_dir:
    pe_upgrade_ver:
    hypervisor: vmpooler
    platform: el-6-x86_64
    template: centos-6-x86_64
    roles:
    - agent
    - master
    - database
    - dashboard
  centos6-32-2:
    pe_dir:
    pe_ver:
    pe_upgrade_dir:
    pe_upgrade_ver:
    hypervisor: vmpooler
    platform: el-6-i386
    template: centos-6-i386
    roles:
    - agent
CONFIG:
  nfs_server: none
  consoleport: 443
  pooling_api: http://vmpooler.delivery.puppetlabs.net/
```

### Single-host SUT layout with Arbitrary Roles

```
$ beaker-hostgenerator centos6-32compile_master,another_role.ma
```

Will generate

```yaml
---
HOSTS:
  centos6-32-1:
    pe_dir:
    pe_ver:
    pe_upgrade_dir:
    pe_upgrade_ver:
    hypervisor: vmpooler
    platform: el-6-i386
    template: centos-6-i386
    roles:
    - agent
    - master
    - compile_master
    - another_role
    frictionless_options:
      main:
        dns_alt_names: puppet
        environmentpath: "/etc/puppetlabs/puppet/environments"
CONFIG:
  nfs_server: none
  consoleport: 443
  pooling_api: http://vmpooler.delivery.puppetlabs.net/
```

## Testing

Beaker Host Generator currently uses both rspec and minitest tests. To run both
at the same time, run:
```bash
bundle exec rake tests
```

### Test Fixtures

Beaker Host Generator makes extensive use of test fixtures to validate its
behavior under specific conditions. An example of such a test fixture is as
follows:

```yaml
---
options_string: "--pe_dir /opt/hello centos6-64mdc"
environment_variables: {}
expected_hash:
  HOSTS:
    centos6-64-1:
      pe_dir: "/opt/hello"
      pe_ver: 
      pe_upgrade_dir: 
      pe_upgrade_ver: 
      hypervisor: vmpooler
      platform: centos-6-x86_64
      template: centos-6-x86_64
      roles:
      - agent
      - master
      - database
      - dashboard
  CONFIG:
    nfs_server: none
    consoleport: 443
    pooling_api: http://vmpooler.delivery.puppetlabs.net/
expected_exception: 
```

These test fixtures are yaml files searched for in the directory
`test/fixtures`. The data structure expected in these files is a hash with four
keys:

- `options_string`: The command line arguments that should be passed to
  `beaker-hostgenerator`
- `environment_variables`: The environment variables that should be set during
  the `beaker-hostgenerator` call.
- `expected_hash`: A hash that should match the output of `beaker-hostgenerator`
  when it is run with `options\_string`
- `expected_exception`: If the `options_string` passed to `beaker-hostgenerator`
  is expected to lead to an exceptional state, this is the name of the exception
  that the fixture test will attempt to match.

#### Generated Fixtures

It is possible to generate test fixtures using the current state of the
`beaker-hostgenerator` library. To do this, call the `generate:fixtures` Rake
task.

However, this is not something that should need to be done very often. If you
are running tests and find that some fixtures no longer work, you have most
likely made a change that incompatibly changes the behavior of
`beaker-hostgenerator` for other users. Use the test fixtures as a guide to
figure out what you did wrong and figure out how to achieve your goal without
potentially breaking `beaker-hostgenerator` for other users.

There are are few circumstances when you should expect to run the
`generate:fixtures` task:

- When you modify the `FixtureGenerator` to generate new fixtures.
- When you need to fix bug (generated hosts are not usable without your change,
  for example).
- When preparing for a major version bump of Beaker Host Generator.


## Support

Support offered by [Puppet Labs](https://puppetlabs.com) may not always be timely
since it is maintained by a tooling support team that is primarily focused on
improving tools, infrastructure, and automation for our Enterprise products.

That being said, we will happily accept and review PRs from community members
interested in extending and using `beaker-hostgenerator` for their own purposes.
See the [contributing][contributing] doc for more information about how to
contribute.

If you have questions or comments, please contact the Beaker team at the
`#puppet-dev` IRC channel on chat.freenode.org

## License

`beaker-hostgenerator` is distributed under the
[Apache License, Version 2.0][apache-v2]. See the [LICENSE][license] file for more details.

[vmpooler]: https://github.com/puppetlabs/vmpooler
[beaker]: https://github.com/puppetlabs/beaker
[license]: LICENSE
[contributing]: CONTRIBUTING.md
[apache-v2]: http://www.apache.org/licenses/LICENSE-2.0.html
