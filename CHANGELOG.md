# Change Log
All notable changes to this project will be documented in this file.

This project makes a strong effort to adhere to [Semantic
Versioning](http://semver.org).

## [0.10.3] - 2017-7-26
- Change ubuntu1604-POWER platform from 'ubuntu-16.04-power8' to
  'ubuntu-16.04-ppc64el'
- Change redhat7-POWER platform from 'redhat-7.3-power8' to 'el-7-ppc64le'

## [0.10.2] - 2017-7-20
- Change redhat7-POWER platform and template values from 'rhel-7.3-power8' to
  'redhat-7.3-power8'

## [0.10.1] - 2017-7-7
- Add platforms:
  - rhel-7.3-power8
  - ubuntu-16.04-power8

## [0.10.0] - 2017-7-7
- Add map data structure support to arbitrary settings, which previously only
  supported lists and primitives. Maps and lists can be combined.

## [0.9.0] - 2017-6-7
- Add list data structure support to arbitrary settings, which previously only
  supported primitive data types.
- Add ability to override default hypervisor settings in the global config
  section.
- Add support for hardware platforms to the ABS hypervisor.
- Add platforms:
  - vro6-64
  - vro7-64

## [0.8.4] - 2017-4-6
- Add platform:
  - windows2012r2_wmf5-64

## [0.8.3] - 2017-2-7
- Add platform:
  - aix-7.2-power
- Remove warning about changing platform defaults in 1.0 release
- Change from using STDERR to $stderr for Ruby redirection purposes

## [0.8.2] - 2017-1-3
- Add platforms:
  - fedora25-32
  - fedora25-64
  - ubuntu1610-32
  - ubuntu1610-64

## [0.8.1] - 2016-12-21
- Add platforms with Japanese language support:
  - windows2012r2_ja-64
  - windows2012r2_ja-6432
- Don't include test files in the gem. This will greatly reduce the overall size
  of the beaker-hostgenerator gem as it will no longer include the 500+ test fixtures.

## [0.8.0] - 2016-10-4
- Improved whitespace support in global and host settings. Spaces are no longer
  removed, so input must be quoted, escaped, or URL-encoded appropriately.

## [0.7.4] - 2016-9-26
- Add platforms:
  - OSX 10.12
  - Windows 2016
- Support for CI.next:
  - Add AlwaysBeScheduling hypervisor
  - Add CLI flag '--templates-only' to reduce the generated output to include
    only the template values from the HOSTS

## [0.7.3] - 2016-8-11
- Add platform:
  - HuaweiOS 6 powerpc

## [0.7.2] - 2016-7-13
- Automatically URL-decode input to support usage in HTTP URLs, such as Jenkins.

## [0.7.1] - 2016-6-29
- Add platforms:
  - Fedora 24 x86_64 and i386
  - Redhat 6 s390x
  - Redhat 7 s390x
  - SLES 11 s390x
  - SLES 12 s390x

## [0.7.0] - 2016-6-13
- Add optional '--global-config' CLI argument to support arbitrary values in the
  general CONFIG section of host files.
- Add '--version' CLI flag to print out the library version to stdout.
- Remove requirement that only valid (read: built-in) hypervisors are generated
  by allowing any arbitrary string to be specified as the hypervisor. If the
  hypervisor specified is not a built-in one there will be no additional
  hypervisor-specific configuration generated.
- Add platforms:
  - aix-5.3-power
  - aix-6.1-power
  - aix-7.1-power
  - solaris-10-sparc
  - solaris-11-sparc

## [0.6.0] - 2016-05-11
- Add new 'none' hypervisor implementation to support static, non-provisioned hosts.
- Add support for arbitrary, per-host key=value settings.

## [0.5.0] - 2016-03-30
- Add platforms:
 - Ubuntu 16.06 x86 and x86_64
- Fix platforms:
 - Cisco XR and NXOS

## [0.4.0] - 2016-02-05
- Add new optional parameters to CLI:
    --pe_upgrade_dir UPGRADE_PATH
        Explicitly set pe_upgrade_dir attribute on generated hosts.
    --pe_upgrade_ver UPGRADE_VERSION
        Explicitly set pe_upgrade_ver attribute on generated hosts.
    --pe_dir PATH
        Explicitly set pe_dir attribute on generated hosts.
    --pe_ver VERSION
        Explicitly set pe_ver attribute on generated hosts.

- Implement data-driven testing approach that separates test logic from test
  data to improve coverage on important code path (BeakerHostGenerator::CLI).

## [0.3.3] - 2016-02-04
- Fix Cisco platforms by setting required parameters for the vmpooler templates.

## [0.3.2] - 2016-01-28
- Change the way we generate the platform string for windows 10 hosts.

## [0.3.1] - 2015-12-31
- Bug fix: Restrict OSINFO v1 to centos-only changes.

## [0.3.0] - 2015-12-30
- Add --osinfo-version flag to allow users to select beaker-hostgenerator 1.x
major versions of the OSINFO data structure.
  - Don't identify "centos" machines as "el" in the platform string.

## [0.2.1] - 2016-01-20
- Fix platforms:
  - Cisco NXOS 5 (x86_64)
    - set Virtual Routing & Forwarding (vrf) to 'management'
    - set ssh username to 'beaker'
  - Cisco eXR 7 (x86_64)
    - set Virtual Routing & Forwarding (vrf) to 'management'
  
## [0.2.0] - 2015-12-22
- Add platforms:
  - Cumulus 2.5 (x86_64)
  - Cisco NXOS 5 (x86_64)
  - Cisco eXR 7 (x86_64)
- Fix platforms:
  - Arista 4 (i386); spec string previously did not include version number.

## [0.1.0] - 2015-12-21
- Add platforms:
  - Arista 4 (i386)
  - windows 2012r2 (x86_64); 32 bit agent
    - sets ruby_arch=x32
  - windows 2008r2 (x86_64); 32 bit agent
    - sets ruby_arch=x32
  - windows 2008 (x86_64); 32 bit agent
    - sets ruby_arch=x32
  - windows 2003r2 (x86_64); 32 bit agent
    - sets ruby_arch=x32
- Set ruby_arch=x64 on a bunch of 64 bit windows platforms.
- Allow beaker-hostgenerator to be called programmatically.
- Fix bug in module/class namespaces that prevented both `beaker` and
`beaker-hostgenerator` from being required.

## [0.0.1] - 2015-10-07
Test beaker-hostgenerator release pipeline (not intended to be a functional
release)

# sqa-utils (old Gem)

## [Unreleased][unreleased]
### Changed
- Updated this changelog for 0.13.3

## [0.13.3] - 2015-04-29
- Add platforms:
  - Ubuntu 15.10 (i386, x86_64)
  - Windows 10 (i386, x86_64)
  - Fedora 23 (i386, x86_64)
  - Debian 9/Stretch (i386, x86_64)
  - OSX 10.11 El Capitan (x86_64)
- Output --help message when no arguments provided (rather than error stack trace)

## [0.13.2] - 2015-04-29
- Add platforms:
  - Ubuntu 15.04 (i386, x86_64)
  - Fedora 22 (i386, x86_64)
  - OSX 10.10 (x86_64)

## [0.13.0] - 2015-04-29
- Add arbitrary role support.
- Add ability to provide per-role configuration settings on each host. Can be
  disabled with --disable-role-config command line option.
- Add command line option to disable default "agent" role.
- Change "vcloud" hypervisior type to "vmpooler", remove unnecessary hypervisor
  configuration.
- Add spec tests for nodespec parsing and role creation.
