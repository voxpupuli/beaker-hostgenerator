# Change Log
All notable changes to this project will be documented in this file.

This project makes a strong effort to adhere to [Semantic
Versioning](http://semver.org).

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
