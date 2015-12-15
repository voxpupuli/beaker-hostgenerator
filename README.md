# Beaker Host Generator

`beaker-hostgenerator` is a command line utility designed to generate beaker
host config files using a compact command line SUT specification.

It currently only supports puppetlabs' internal [vmpooler][vmpooler] templates,
but is designed in a way that makes it possible to easily add support for
additional hypervisor templates (any hypervisor type supported by
[beaker][beaker]).

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
