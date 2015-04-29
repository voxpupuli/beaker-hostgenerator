# Change Log
All notable changes to this project will be documented in this file.

This project makes a strong effort to adhere to [Semantic
Versioning](http://semver.org).

## [Unreleased][unreleased]
### Changed
- Added this changelog

## [0.13.0] - 2015-04-29
- Add arbitrary role support.
- Add ability to provide per-role configuration settings on each host. Can be
  disabled with --disable-role-config command line option.
- Add command line option to disable default "agent" role.
- Change "vcloud" hypervisior type to "vmpooler", remove unnecessary hypervisor
  configuration.
- Add spec tests for nodespec parsing and role creation.
