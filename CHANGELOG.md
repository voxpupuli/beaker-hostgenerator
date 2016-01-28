# Change Log
All notable changes to this project will be documented in this file.

This project makes a strong effort to adhere to [Semantic
Versioning](http://semver.org).

## [Unreleased][unreleased]
### Changed

## [0.3.2] - 2016-01-28
- Change the way we generate the platform string for windows 10 hosts.

## [0.3.1] - 2015-12-31
- Bug fix: Restrict OSINFO v1 to centos-only changes.

## [0.3.0] - 2015-12-30
- Add --osinfo-version flag to allow users to select beaker-hostgenerator 1.x
major versions of the OSINFO data structure.
  - Don't identify "centos" machines as "el" in the platform string.

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
