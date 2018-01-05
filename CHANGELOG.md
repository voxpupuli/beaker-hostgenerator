# Change Log
All notable changes to this project will be documented in this file.

This project makes a strong effort to adhere to [Semantic
Versioning](http://semver.org).

## [1.1.5] - 2018-01-05
- Add support for amazon7 (AmazonLinux v2)

## [1.1.4] - 2017-11-15
- Update abs template string for AARCH64

## [1.1.3] - 2017-10-27
- Add platforms:
  - osx1013-64
  - redhat7-AARCH64
  - windows2012r2_core-64
  - windows2012r2_core-6432
  - windows2016_core-64
  - windows2016_core-6432
- Fix to platform:
  - amazon6-64

## [1.1.2] - 2017-10-13
- Add platform:
  - cisconxhw-64

## [1.1.1] - 2017-9-27
- Add platform:
  - amazon-6-x86_64

## [1.1.0] - 2017-9-7
- Add new 'packaging_platform' value to the OSes we build packages for to
  support new install methods in Beaker.

## [1.0.2] - 2017-8-21
- Add platforms:
  - sles-12-power8
  - fedora-26-x86_64

## [1.0.1] - 2017-8-14
- Support empty string as the value of version by returning nil from pe_dir()
- Support unparseable/unknown versions by returning empty string from pe_dir()

## [1.0.0] - 2017-8-14
- Rewrite pe_dir() to provide RC builds and to determine build source just from
  the pe_version format.

  Previously, source was either archives/releases if version and family
  were the exact same string, otherwise ci-ready.

  Recently we have added archives/internal which houses rc tagged builds
  long term (ci-ready has a two-week life span).  These internal archive
  releases let us test rc builds for internal consumption, but introduced
  a third source.

  Fourth source, actually, I'd forgotten that we already had dev version
  strings with PEZ in them that need to be sourced from
  feature/ci-ready...

  The patch bases everything off the version because the four cases are
  mutually exclusive, and the previous determination of a release source
  based on version == family doesn't make sense for anything but a release
  version.  (If you supplied dev builds for both, for example, you
  would get a host config trying to lookup a dev build in archive/releases
  where it would not be found...)

  This patch keeps the behavior of returning nil if either version or
  family is nil so as to preserve a fallback behavior that would have
  Beaker instead pick up pe_dir from environment variables: BEAKER_PE_DIR
  or pe_dist_dir.

- Drop use of pe_family/pe_upgrade_family

  The pe_family and pe_upgrade_family environment variables were only
  being used as a means of signaling that we want pe_dir to be
  archives/releases. (If pe_version and pe_family were equal, we'd return
  archives/releases for pe_dir).  This behavior was changed in the
  previous commit to instead base the tarball source on the version string
  format.

  The only other behavior that passing family had was that if either
  verison or family were nil, pe_dir would be nil. So theoretically, if
  you only set pe_version to some valid version, you would get a beaker
  config with no pe_dir set, and Beaker could then set pe_dir based on
  BEAKER_PE_DIR or pe_dist_dir environment variables.

  This commit removes family so that we can clean up pipelines which would
  otherwise be setting pe_family just for the purpose of avoiding this
  behavior.

  It is potentially a breaking change if someone was relying on the
  absence of pe_family to allow Beaker to set pe_dir as mentioned above.

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
