## [1.1.26](https://github.com/voxpupuli/modulesync/tree/1.1.26) (2019-02-19)
- Add platform
  - debian10-64
  - debian10-32
- Change amazon7-ARM64 to use el-7-aarch64 platform

## [1.1.25] - 2019-01-07
- Fix --hypervisor vagrant_libvirt

## [1.1.24] - 2019-01-03
- Add platform:
  - amazon7-ARM64

## [1.1.23] - 2018-12-13
- Add platforms:
  - redhat8-64
  - osx1014-64

## [1.1.22] - 2018-11-21
- Add vagrant hypervisor for debian plaforms

## [1.1.21] - 2018-11-19
- Disable getty when using docker

## [1.1.20] - 2018-11-14
- Add gnupg to docker_image_commands for debian9-64
- Add platform:
  - fedora29-64

## [1.1.19] - 2018-10-18
- Add platforms:
  - solaris114-32
  - solaris114-64

## [1.1.18] - 2018-10-10
- Add platform:
  - ubuntu1810-64

## [1.1.17] - 2018-10-05
- Add platforms:
  - windows2019_core-64
  - windows2019_core-6432

## [1.1.16] - 2018-09-04
- Install iproute2 on ubuntu18.04 for containers

## [1.1.15] - 2018-08-16
- Add platforms:
  - panos61-64
  - panos71-64
## Details

### 0.9.0 - 7 Jun, 2017 (06b6a0da)

* (GEM) update beaker-hostgenerator version to 0.9.0 (06b6a0da)

* Merge pull request #80 from puppetlabs/prepare-for-release (b7a83889)


```
Merge pull request #80 from puppetlabs/prepare-for-release

(MAINT) Update CHANGELOG for 0.9.0 release
```
* (MAINT) Update CHANGELOG for 0.9.0 release (aae2e698)

* (MAINT) Fix rendering issue in README and update TOC (bc92bd07)

* (QENG-4945) Add support for arbitrary lists (e75f1e7e)


```
(QENG-4945) Add support for arbitrary lists

Before, we had no way to add lists to configurations. This adds
a new bracket syntax within arbitrary settings in order to parse out any lists the user may want to
add in.
```
* Merge pull request #79 from puppetlabs/qeng-5041 (990b6081)


```
Merge pull request #79 from puppetlabs/qeng-5041

(QENG-5041) Add vRO to support platforms
```
* (QENG-5041) Add vRO to support platforms (22b7c670)


```
(QENG-5041) Add vRO to support platforms

This adds both vro-6-x86_64 and vro-7-x86_64. The templates
already exist within vmpooler
```
* Merge pull request #77 from puppetlabs/fix-default-config-hypervisors (988476e1)


```
Merge pull request #77 from puppetlabs/fix-default-config-hypervisors

(maint) The hypervisor defaults are not overwritable
```
* Merge pull request #76 from puppetlabs/qeng4965/add-abs-hardware-support (874f473f)


```
Merge pull request #76 from puppetlabs/qeng4965/add-abs-hardware-support

(QENG-4965) Add ABS support for hardware platforms
```
* (MAINT) Delete duplicate keys from test helper hash (0fe2c0ac)

* (MAINT) Prefer underscores over dashes in file names (efe8b7b1)


```
(MAINT) Prefer underscores over dashes in file names

Ruby prefers that you not use dashes in your .rb filenames, so this commit
renames abs-support.rb to abs_support.rb
```
* (maint) The hypervisor defaults are not overwritable (1a44141b)


```
(maint) The hypervisor defaults are not overwritable
Before this change the code would pull and merge the hypervisor defaults on top of any
user provided --global-config block. This reverses the logic to use defaults only
if the key is not specified in the --global-config section. This specifically
enables overwritting the pooling_api for the vmpooler hypervisor, as it is the
only one with a default global_config() method implementation. Also added it's
respective test
```
* (QENG-4965) Add ABS support for hardware platforms (a9ddf44b)


```
(QENG-4965) Add ABS support for hardware platforms

This commit makes the hardware platforms compatible with the ABS hypervisor and
the --templates-only switch to enable hardware support in Jenkins via ABS.
```
### <a name = "0.8.4">0.8.4 - 6 Apr, 2017 (77943fb2)

* (HISTORY) update beaker-hostgenerator history for gem release 0.8.4 (77943fb2)

* (GEM) update beaker-hostgenerator version to 0.8.4 (d80eb358)

* Merge pull request #74 from puppetlabs/prepare-for-release (43405262)


```
Merge pull request #74 from puppetlabs/prepare-for-release

(MAINT) Update CHANGELOG for 0.8.4 release
```
* (MAINT) Update CHANGELOG for 0.8.4 release (26cd2eef)

* Merge pull request #73 from glennsarti/2012r2-wmf5 (d00a1d63)


```
Merge pull request #73 from glennsarti/2012r2-wmf5

(MODULES-4667) Add Windows 2012R2 WMF5 VMPooler image
```
* (MODULES-4667) Add Windows 2012R2 WMF5 VMPooler image (8b293890)


```
(MODULES-4667) Add Windows 2012R2 WMF5 VMPooler image

This commit adds the win-2012r2-wmf5-x86_64 vmpooler image, which is a variation
on the Windows Sever 2012R2 64bit image.
```
### <a name = "0.8.3">0.8.3 - 7 Feb, 2017 (79e8d717)

* (HISTORY) update beaker-hostgenerator history for gem release 0.8.3 (79e8d717)

* (GEM) update beaker-hostgenerator version to 0.8.3 (12bfa089)

* Merge pull request #72 from puppetlabs/maint/prepare-for-release (cc5a3ce6)


```
Merge pull request #72 from puppetlabs/maint/prepare-for-release

(MAINT) Update CHANGELOG for 0.8.3 release
```
* (MAINT) Update CHANGELOG for 0.8.3 release (6d3900a9)

* Merge pull request #71 from ferglor/BKR-1032 (cca29c01)


```
Merge pull request #71 from ferglor/BKR-1032

(BKR-1032) Switched from using STDERR to $stderr
```
* (BKR-1032) Switched from using STDERR to $stderr (7d4f8197)

* Merge pull request #70 from puppetlabs/qeng4019/remove-warning-message (087df5a5)


```
Merge pull request #70 from puppetlabs/qeng4019/remove-warning-message

(QENG-4019) Remove warning message about changing defaults
```
* (QENG-4019) Remove warning message about changing defaults (d3e19a40)


```
(QENG-4019) Remove warning message about changing defaults

This warning message was added a while ago to inform users of an upcoming
breaking change. We're no longer certain that we'll be making the breaking
change though, so the warning is a bit misleading.

Furthermore, we're now trying to silence this message when beaker-hostgenerator
is used programatically within Beaker.

There will likely be more changes that are outlined in the linked ticket, such
as adding a new CLI switch to toggle between specific & generic platform names.
```
* Merge pull request #68 from branan/pa-893-aix-7.2 (48b9eb04)


```
Merge pull request #68 from branan/pa-893-aix-7.2

(PA-893) Add AIX 7.2
```
* (PA-893) Add AIX 7.2 (8ff6a8c6)

### <a name = "0.8.2">0.8.2 - 3 Jan, 2017 (a61487bf)

* (HISTORY) update beaker-hostgenerator history for gem release 0.8.2 (a61487bf)

* (GEM) update beaker-hostgenerator version to 0.8.2 (b1ff2e54)

* Merge pull request #67 from puppetlabs/maint/prepare-for-release (214fcb06)


```
Merge pull request #67 from puppetlabs/maint/prepare-for-release

(MAINT) Update CHANGELOG for 0.8.2 release
```
* (MAINT) Update CHANGELOG for 0.8.2 release (b5f9684d)

* Merge pull request #66 from ScottGarman/ubuntu1610 (fb9dbbb1)


```
Merge pull request #66 from ScottGarman/ubuntu1610

Add Ubuntu 16.10 platforms and test fixtures
```
* (PA-716) Add Ubuntu 16.10 test fixtures (bb8233c3)

* (PA-716) Add support for Ubuntu 16.10 i386 and x86_64 platforms (d8ecc7d0)

* Merge pull request #65 from ScottGarman/fedora25 (eb42f28d)


```
Merge pull request #65 from ScottGarman/fedora25

Add Fedora 25 platforms and test fixtures
```
* (BKR-984) Add fedora25 test fixtures (76cd6543)


```
(BKR-984) Add fedora25 test fixtures

These were generated by running rake generate:fixtures.
```
* (BKR-984) Add support for Fedora 25 i386 and x86_64 platforms (ba50620c)

### <a name = "0.8.1">0.8.1 - 21 Dec, 2016 (2648029d)

* (HISTORY) update beaker-hostgenerator history for gem release 0.8.1 (2648029d)

* (GEM) update beaker-hostgenerator version to 0.8.1 (5466486c)

* Merge pull request #64 from puppetlabs/maint/prepare-for-release (2dd91be2)


```
Merge pull request #64 from puppetlabs/maint/prepare-for-release

(MAINT) Update CHANGELOG for 0.8.1 release
```
* (MAINT) Update CHANGELOG for 0.8.1 release (26a6d6a2)

* Merge pull request #63 from glennsarti/add-windows-2012r2-jp (55b13176)


```
Merge pull request #63 from glennsarti/add-windows-2012r2-jp

(BKR-1013) Add Windows 2012R2 Japanese Template
```
* (BKR-1013) Add Windows 2012R2 Japanese Template (e72e9401)


```
(BKR-1013) Add Windows 2012R2 Japanese Template

This commit adds the Japanese Windows 2012 R2 VMPooler template in preparation
of testing non-US English systems in Beaker.
```
* Merge pull request #62 from puppetlabs/maint_delete-acceptance-tests (16b0a3b2)


```
Merge pull request #62 from puppetlabs/maint_delete-acceptance-tests

(MAINT) Remove acceptance testing
```
* Merge pull request #61 from puppetlabs/maint_exclude-test-files-from-gem (f85e0376)


```
Merge pull request #61 from puppetlabs/maint_exclude-test-files-from-gem

(MAINT) Delete test_files directive to keep fixtures out of the gem
```
* (MAINT) Specify all dependencies in gemspec file (e0134744)


```
(MAINT) Specify all dependencies in gemspec file

There was only 1 dependency still being specified in the Gemfile, so to clean
things up a little bit this commit just moves it over to the gemspec file
instead.

After all, we're building a gem (not an app) so we should prefer gemspec over
Gemfile.
```
* (MAINT) Remove acceptance testing (39e43aef)


```
(MAINT) Remove acceptance testing

This deletes everything related to acceptance testing.

We had no tests, and we have no intentions of adding any. We started to lay out
the groundwork for acceptance testing a while ago with the "acceptance/"
directory, `beaker` test dependency, and the `acceptance` Rake task.

This commit deletes that groundwork, as it is out of date and just getting in
the way at this point.  If we decide to add acceptance tests in the future, it
will likely look different than this anyway.
```
* (MAINT) Delete test_files directive to keep fixtures out of the gem (60559c93)


```
(MAINT) Delete test_files directive to keep fixtures out of the gem

This gemspec directive `test_files` will cause the files it references to be
included in the built gem so they can be used during the `gem test` command.

We do not intend to support the ability for users to run `gem test`, and
furthermore this gem subcommand doesn't even exist anymore.
```
* Merge pull request #60 from puppetlabs/maint_exclude-test-files-from-gem (27f0c177)


```
Merge pull request #60 from puppetlabs/maint_exclude-test-files-from-gem

(MAINT) Exclude test files from built gem
```
* (MAINT) Exclude test files from built gem (2dba0975)


```
(MAINT) Exclude test files from built gem

This project has a TON of test fixtures that are not necessary in production,
yet we were still bundling them into the gem.

We don't need to include any of these, they were just making the resulting gem
significantly larger.
```
* (MAINT) Remove 'features' from gemspec test files (3e16db88)


```
(MAINT) Remove 'features' from gemspec test files

There is no 'features' directory or files so it doens't make sense in the
gemspec.
```
* (MAINT) Add Gemfile.local to gitignore (a1f16380)

* (MAINT) Remove file encoding comment from gemspec file (3251469b)


```
(MAINT) Remove file encoding comment from gemspec file

We don't need this for Ruby, it's only for your text editor, and it's annoying
as it causes some editors to prompt you for confirmation before opening the file
and parsing the encoding comment.
```
* Merge pull request #59 from puppetlabs/theshanx-patch-1 (a365eb7a)


```
Merge pull request #59 from puppetlabs/theshanx-patch-1

(maint) Add internal_list key to MAINTAINERS
```
* (maint) Add internal_list key to MAINTAINERS (99fc75ee)


```
(maint) Add internal_list key to MAINTAINERS

This change adds a reference to the Google group the maintainers are associated with.
```
### <a name = "0.8.0">0.8.0 - 4 Oct, 2016 (2e6dc11e)

* (HISTORY) update beaker-hostgenerator history for gem release 0.8.0 (2e6dc11e)

* (GEM) update beaker-hostgenerator version to 0.8.0 (291854ec)

* Merge pull request #58 from puppetlabs/maint (82d9fc2a)


```
Merge pull request #58 from puppetlabs/maint

(MAINT) Prepare for 0.8.0 release
```
* (MAINT) Prepare for 0.8.0 release (a6346c24)

* Merge pull request #57 from puppetlabs/bk934/support-whitespace (93abe32c)


```
Merge pull request #57 from puppetlabs/bk934/support-whitespace

(BKR-934) Allow for whitespace in settings
```
* (BKR-934) Allow for whitespace in settings (487f3f65)


```
(BKR-934) Allow for whitespace in settings

Previously all whitespace was automatically removed from all input. This
commit removes that behavior, allowing for values with whitespace in
them to be properly generated.

This change means users are responsible for properly quoting, escaping,
or URL-encoding the whitespace as necessary.
```
### <a name = "0.7.4">0.7.4 - 26 Sep, 2016 (1e102ccd)

* (HISTORY) update beaker-hostgenerator history for gem release 0.7.4 (1e102ccd)

* (GEM) update beaker-hostgenerator version to 0.7.4 (09c62ae1)

* Merge pull request #56 from puppetlabs/maint (44882551)


```
Merge pull request #56 from puppetlabs/maint

(MAINT) Prepare for 0.7.4 release
```
* (QENG-4407) Return proper JSON map (88581c56)


```
(QENG-4407) Return proper JSON map

Previously the --templates-only switch would output a custom CSV-style
format, plus it repeated platforms rather than tallying them up.

This commit changes the output format to be a JSON map, with the
platforms as keys and the total counts as values.
```
* Merge pull request #53 from puppetlabs/add-maintainers-file (126620cf)


```
Merge pull request #53 from puppetlabs/add-maintainers-file

(MAINT) Add MAINTAINERS file
```
* (MAINT) Add MAINTAINERS file (b73a2ede)

* (MAINT) Prepare for 0.7.4 release (1cc9c3fc)

* Merge pull request #51 from puppetlabs/qeng4204/add-templates-only-cli (a7196b52)


```
Merge pull request #51 from puppetlabs/qeng4204/add-templates-only-cli

(QENG-4204) Add CLI flag to only generate templates
```
* (QENG-4204) Add CLI flag to only generate templates (7c4342f8)


```
(QENG-4204) Add CLI flag to only generate templates

This adds a CLI switch '--templates-only' that will reduce the generated
output to include only the template values from the HOSTS.
```
* Merge pull request #48 from puppetlabs/qeng4204/create-abs-hypervisor (ec1b80d2)


```
Merge pull request #48 from puppetlabs/qeng4204/create-abs-hypervisor

(QENG-4204) Add AlwaysBeScheduling hypervisor
```
* Merge pull request #50 from puppetlabs/qeng-4176 (aecb44a6)


```
Merge pull request #50 from puppetlabs/qeng-4176

(QENG-4176 & QENG-4180) Add OSX 10.12 and Windows 2016
```
* (QENG-4176 & QENG-4180) Add OSX 10.12 and Windows 2016 (0d8ad08a)


```
(QENG-4176 & QENG-4180) Add OSX 10.12 and Windows 2016

Added OSX 10.12 (Sierra) and Windows Server 2016 to
supported beaker-hostgenerator platforms
```
* (QENG-4204) Add AlwaysBeScheduling hypervisor (87559142)


```
(QENG-4204) Add AlwaysBeScheduling hypervisor

This commit adds a new hypervisor called 'abs' that will support
generating configurations necessary for working with CI.next and the
AlwaysBeScheduling service.

Currently, the behavior of the abs hypervisor is basically the same as
the vmpooler hypervisor. The only difference is it doesn't fixup the
nodes to support old PE versions.

Having a built-in hypervisor for ABS alleviates the need for users to
manually override the hypervisor key on each node.
```
### <a name = "0.7.3">0.7.3 - 11 Aug, 2016 (87c75523)

* (HISTORY) update beaker-hostgenerator history for gem release 0.7.3 (87c75523)

* (GEM) update beaker-hostgenerator version to 0.7.3 (9ad5f770)

* (maint) Update CHANGELOG for 0.7.3 release (9e9c1b82)

* Merge pull request #47 from puppetlabs/maint (165cd14a)


```
Merge pull request #47 from puppetlabs/maint

(maint) Update CHANGELOG for 0.7.3 release
```
* Merge pull request #46 from puppetlabs/qeng4179/add-huaweios6-platform (3a871959)


```
Merge pull request #46 from puppetlabs/qeng4179/add-huaweios6-platform

(QENG-4179) Add HuaweiOS 6 platform
```
* (QENG-4179) Add test HuaweiOS test fixtures (ba951da2)

* (QENG-4179) Add HuaweiOS 6 platform (4c9905c0)

* Merge pull request #45 from puppetlabs/maint (42b2e6f2)


```
Merge pull request #45 from puppetlabs/maint

(MAINT) Add URL encoding references to README
```
* (MAINT) Add URL encoding references to README (84dfdb29)

### <a name = "0.7.2">0.7.2 - 13 Jul, 2016 (cee53bcc)

* (HISTORY) update beaker-hostgenerator history for gem release 0.7.2 (cee53bcc)

* (GEM) update beaker-hostgenerator version to 0.7.2 (edc8971b)

* (MAINT) Update CHANGELOG for 0.7.2 release (f1270d44)

* Merge pull request #44 from nwolfe/maint/master/prepare-for-release (eb45282f)


```
Merge pull request #44 from nwolfe/maint/master/prepare-for-release

(MAINT) Update CHANGELOG for 0.7.2 release
```
* Merge pull request #43 from nwolfe/qeng4034/support-url-encoding (e4e55d3a)


```
Merge pull request #43 from nwolfe/qeng4034/support-url-encoding

(QENG-4034) Automatically URL-decode raw input
```
* (QENG-4034) Automatically URL-decode raw input (e6d1c1dc)


```
(QENG-4034) Automatically URL-decode raw input

This commit adds a "pre-processing" step to the Parser that will always
attempt to URL-decode the input before parsing it. This behavior is
necessary to support specifying arbitrary settings in the input string
when the input ends up as part of an HTTP URL, such as almost every
usage we currently have in Jenkins.
```
### <a name = "0.7.1">0.7.1 - 29 Jun, 2016 (be332325)

* (HISTORY) update beaker-hostgenerator history for gem release 0.7.1 (be332325)

* (GEM) update beaker-hostgenerator version to 0.7.1 (530baa09)

* Merge pull request #41 from nwolfe/maint/master/prepare-for-release (d576464b)


```
Merge pull request #41 from nwolfe/maint/master/prepare-for-release

(MAINT) Update CHANGELOG for 0.7.1 release
```
* Merge pull request #42 from nwolfe/maint/master/regenerate-fixture-for-new-platforms (1e1b7f47)


```
Merge pull request #42 from nwolfe/maint/master/regenerate-fixture-for-new-platforms

(MAINT) Regenerate test fixtures for new platforms
```
* (MAINT) Regenerate test fixtures for new platforms (cc4fa0ef)


```
(MAINT) Regenerate test fixtures for new platforms

I blew away the whole fixtures/generated/ directory and regenerated them
all again, so the new platforms will be included and tested.
```
* Merge pull request #39 from nwolfe/qeng3626-add-sles11-s390x (2155fb79)


```
Merge pull request #39 from nwolfe/qeng3626-add-sles11-s390x

(QENG-3626) Add sles-11-s390x platform
```
* Merge pull request #38 from puppetlabs/qeng-3815 (8bcbcfef)


```
Merge pull request #38 from puppetlabs/qeng-3815

(QENG-3815) Adding sles12-s390x
```
* Merge pull request #40 from puppetlabs/QENG-3960 (c0d76e1d)


```
Merge pull request #40 from puppetlabs/QENG-3960

(QENG-3960, QENG-3817, QENG-3816) - Updated for Fedora 24 (x86_64, i3…
```
* (MAINT) Update CHANGELOG for 0.7.1 release (56b71af5)

* (QENG-3626) Add sles-11-s390x platform (c09b8a87)

* (QENG-3960, QENG-3817, QENG-3816) - Updated for Fedora 24 (x86_64, i386), el-7-s390x, and el-6-s390x (d88aba55)

* (QENG-3815) Adding sles12-s390x (a95646ea)


```
(QENG-3815) Adding sles12-s390x

Adding sles12-s390x. No vmpooler
```
### <a name = "0.7.0">0.7.0 - 13 Jun, 2016 (f0aafe8d)

* (HISTORY) update beaker-hostgenerator history for gem release 0.7.0 (f0aafe8d)

* (GEM) update beaker-hostgenerator version to 0.7.0 (4792554b)

* Merge pull request #36 from nwolfe/qeng3987/release-0.7.0 (11256701)


```
Merge pull request #36 from nwolfe/qeng3987/release-0.7.0

(QENG-3987) Update CHANGELOG for 0.7.0 release
```
* (QENG-3987) Update CHANGELOG for 0.7.0 release (2f9fa77c)

* Merge pull request #33 from nwolfe/qeng3811-add-aix-and-sparc-platforms (9e73e059)


```
Merge pull request #33 from nwolfe/qeng3811-add-aix-and-sparc-platforms

(QENG-3811) Add AIX and Solaris SPARC platforms
```
* Merge pull request #35 from nwolfe/maint/alphabetize-test-fixtures (26ae944e)


```
Merge pull request #35 from nwolfe/maint/alphabetize-test-fixtures

(MAINT) Sort platforms alphabetically
```
* Merge pull request #34 from nwolfe/qeng3946-support-arbitrary-hypervisors (4d018b46)


```
Merge pull request #34 from nwolfe/qeng3946-support-arbitrary-hypervisors

(QENG-3946) Support arbitrary hypervisors
```
* (QENG-3946) Support arbitrary hypervisors (cf62fc5e)


```
(QENG-3946) Support arbitrary hypervisors

This commit allows unknown hypervisors to be specified by the user.
Previously, if the hypervisor specified by the user was not one of the
valid, built-in implementations then an error was thrown notifying the
user that an invalid hypervisor was requested.
Now, this is no longer an error, and instead the host generation will
continue as normal but there will be no hypervisor-specific
configuration. The name of the unknown hypervisor will be the value of
the hypervisor configuration of the hosts.

To implement this, we can repurpose the special `Hypervisor::None`
implementation to instead represent an unknown (but equally valid)
hypervisor. The unknown name will now be the value of `hypervisor` in
the generated config, where it used to be `hypervisor: none`.

For example:
  $ .. centos6-64{hypervisor=custom}
  ---
  HOSTS:
    centos6-64-1:
      pe_dir:
      pe_ver:
      pe_upgrade_dir:
      pe_upgrade_ver:
      platform: el-6-x86_64
      hypervisor: custom
      roles:
      - agent
  CONFIG:
    nfs_server: none
    consoleport: 443
```
* (QENG-3811) Regenerate fixtures with new platforms (dbd40c80)


```
(QENG-3811) Regenerate fixtures with new platforms

Our fixture generation isn't quite deterministic, and adding a new
platform somehow causes unrelated platform fixtures to be changed.

This commit deletes the entire `test/fixtures/generated` directory and
regenerates them anew, with new fixtures for the new AIX and Solaris
SPARC platforms.
```
* (QENG-3811) Add AIX and Solaris SPARC platforms (8c5eb30d)

* (MAINT) Regenerate test fixtures and isolate them (d17d2341)


```
(MAINT) Regenerate test fixtures and isolate them

Since we sorted the platforms alphabetically, the fixture generation
results in different filenames. Basically every time we modify
Data#platforms() we should regenerate the fixtures so we have all
platforms covered.

This moves the generated fixtures into a new directory called
`test/fixtures/generated/` so it's easier to work with them and not have
the manually created fixtures get in the way.
```
* (MAINT) Sort platforms alphabetically (2376853e)


```
(MAINT) Sort platforms alphabetically

Just so it's easier to navigate the large structure in the code.
```
* Merge pull request #32 from nwolfe/qeng3808-alphanumeric-architectures (92eb8545)


```
Merge pull request #32 from nwolfe/qeng3808-alphanumeric-architectures

(QENG-3808) Support uppercase alphanumeric architectures
```
* Merge pull request #31 from nwolfe/qeng3377-fix-version-flag (7bedf39f)


```
Merge pull request #31 from nwolfe/qeng3377-fix-version-flag

(QENG-3377) Add --version CLI flag
```
* Merge pull request #30 from nwolfe/qeng3920-arbitrary-global-config-support (ffe6078a)


```
Merge pull request #30 from nwolfe/qeng3920-arbitrary-global-config-support

(QENG-3920) Global host config CLI configuration support
```
* (QENG-3808) Support uppercase alphanumeric architectures (0fc1ba77)


```
(QENG-3808) Support uppercase alphanumeric architectures

This commit adds support for uppercase-only alphanumeric architecture
bits in platform names. For example, we can support things like
"POWER", "POWER7", "S390X" instead of just "32" or "64".

Uppercase letters allow for backwards compatibility when roles are
specified, which come after the architecture bit. This implementation
relies on the fact that the role and arbitrary role characters are
only lowercase.

This allows us to distinguish between the architecture "POWER" and the
role "m" when parsing the spec "POWERm", as in "aix71-POWERm".
```
* (QENG-3377) Add --version CLI flag (2ddec220)


```
(QENG-3377) Add --version CLI flag

This commit adds a -v/--version CLI flag to print the version number.

This also refactors the flow-of-control to remove the need for the
SafeEarlyExit exception by moving all output-generating codepaths out of
the initialize method and into the execute method, and teasing apart the
--list and default generation codepaths. The execute method
now chooses the code path based on the CLI options set in initialize.

While we no longer throw a SafeEarlyExit exception, it's effectively
part of the API so we must wait until the appropriate time/release to
delete it. Existing usages of it should not be broken with the changes
in this commit.
```
* (QENG-3920) Global host config CLI configuration support (151918d9)


```
(QENG-3920) Global host config CLI configuration support

This commit adds CLI support for specifying global configuration
settings that will be included in the CONFIG section.

For example:

  $ beaker-hostgenerator --global-config {master=headless} redhat7-64m
  ---
  HOSTS:
    redhat7-64-1:
      pe_dir:
      pe_ver:
      pe_upgrade_dir:
      pe_upgrade_ver:
      hypervisor: vmpooler
      platform: el-7-x86_64
      template: redhat-7-x86_64
      roles:
      - agent
      - master
  CONFIG:
    nfs_server: none
    consoleport: 443
    master: headless
    pooling_api: http://vmpooler.delivery.puppetlabs.net/
```
### <a name = "0.6.0">0.6.0 - 11 May, 2016 (c807eb0d)

* (HISTORY) update beaker-hostgenerator history for gem release 0.6.0 (c807eb0d)

* (GEM) update beaker-hostgenerator version to 0.6.0 (4a8ee90e)

* Merge pull request #29 from nwolfe/maint/master/prepare-for-release (7e0decc0)


```
Merge pull request #29 from nwolfe/maint/master/prepare-for-release

(maint) Prepare for 0.6.0 release
```
* (maint) Prepare for 0.6.0 release (c15c1bf6)

* Merge pull request #28 from nwolfe/qeng3276/none-hypervisor-and-host-settings (d105e4bd)


```
Merge pull request #28 from nwolfe/qeng3276/none-hypervisor-and-host-settings

(QENG-3276) Add None hypervisor and per-host settings support
```
* (QENG-3276) Minor refactorings; failing test fixture (b0926b22)


```
(QENG-3276) Minor refactorings; failing test fixture

This commit includes the following minor refactorings based on feedback:
* Inline if block surrounding arbitrary_settings['hostname']
* Strip the `__` name prefix from `__generate_host_roles!` and make
  private; adjust spec test accordingly
* Change test fixture `expected_exception` support to not use the
  dangerous `eval`, and added `per-host-settings/malformed-input.yaml`
  test fixture to exercise the support
```
* (QENG-3276) Update CHANGELOG (0a170d42)


```
(QENG-3276) Update CHANGELOG

This commit adds notes for the next release regarding the 'none'
hypervisor and arbitrary key-value host settings support.
```
* (QENG-3276) Add more parser tests for failures (b80d94ab)


```
(QENG-3276) Add more parser tests for failures

This commit adds tests that validate the proper exceptions are thrown
when invalid arbitrary host settings are provided.

This also expands host-setting support to include arbitrary whitespace
to allow for more human-readable input.
```
* (MAINT) Wire up expected_excpetion test fitxure support (78cccb14)


```
(MAINT) Wire up expected_excpetion test fitxure support

This commits finishes the work necessary to support expected exceptions
defined in the test fixture YAML files.
```
* (QENG-3276) Move host role code into Roles module (78a2679e)


```
(QENG-3276) Move host role code into Roles module

This commit moves the ROLES map and custom role config map out of the
Data and Generator classes and into the Roles class.
This also changes the implementation of custom role configuration from
being a meta-programming method call into a standard map index.
```
* (QENG-3276) Extract code into new Parser module (9764fd7e)


```
(QENG-3276) Extract code into new Parser module

This commit moves the NODE_REGEX constant and handful of methods tightly
coupled to it into a new module called Parser. This module is
responsible for dealing with the raw user input string and turning it
into data structures that the Generator and hypervisors can operate on.
```
* (QENG-3276) Minor method refactoring (ce763dc0)


```
(QENG-3276) Minor method refactoring

This commit renames a method, marks some methods as private, and
extracts some logic into its own method.
```
* (QENG-3276) Update README (fd99cc9f)


```
(QENG-3276) Update README

This commit updates the README to include an example of the new 'none'
hypervisor and per-host settings.

Also rename "Puppet Labs" references to just "Puppet".
```
* (QENG-3276) Update CLI help/usage text (7d85dff4)


```
(QENG-3276) Update CLI help/usage text

This commit updates the CLI help text to mention the new arbitrary host
settings support, and include the list of valid hypervisors when the
`--list` option is given.
```
* (QENG-3276) Test fixtures for hypervisor and settings (34d4e649)


```
(QENG-3276) Test fixtures for hypervisor and settings

This commit adds a couple hand-made test fixtures that exercise the new
"none" hypervisor and arbitrary host settings support.
```
* Merge pull request #27 from nwolfe/maint/master/decouple-generator-and-hypervisors (52293374)


```
Merge pull request #27 from nwolfe/maint/master/decouple-generator-and-hypervisors

(maint) Decouple hypervisors from generator
```
* (QENG-3276) Add None hypervisor and per-host settings support (ab38abef)


```
(QENG-3276) Add None hypervisor and per-host settings support

This commit adds a new "none" hypervisor to support non-provisioned
hosts. Non-provisioned hosts require a handful of other host settings to
be specified in order for Beaker to use it properly, so this commit also
adds support for arbitrary key-value host settings.

For example:

 $ .. centos6-64m{hypervisor=none,hostname=my-host,vmhostname=othername}
 ---
 HOSTS:
   my-host:
     pe_dir:
     pe_ver:
     pe_upgrade_dir:
     pe_upgrade_ver:
     platform: el-6-x86_64
     hypervisor: none
     vmhostname: othername
     roles:
     - agent
     - master
 CONFIG:
   nfs_server: none
   consoleport: 443
```
* (maint) Docstrings for new hypervisor architecture (9c35595f)


```
(maint) Docstrings for new hypervisor architecture

This commit adds docstrings to modules and methods, specifically the
BeakerHostGenerator::Hypervisor and BeakerHostGenerator::Data modules.
```
* (maint) Generate multi-platform test fixtures (996578cb)


```
(maint) Generate multi-platform test fixtures

To help with test coverage, this adds a directory full of generated
test fixtures with multi-platform hosts in a form similar to
"centos6-64m-debian8-32-sles12-64a". Two of the three hosts have a
random role assigned.
```
* (maint) New generated windows test fixtures (2591347e)


```
(maint) New generated windows test fixtures

The rake task 'generate:fixtures' produced several new Windows fixtures.
Perhaps we had previously updated the code to add support for more
Windows platforms, but we forgot to re-generate the test fixtures?
```
* (maint) Decouple hypervisors from generator (aa39202e)


```
(maint) Decouple hypervisors from generator

This commit is a large refactor that teases apart the generate code from
the hypervisor code.

Previously the VMPooler hypervisor class was a subclass of the Generator
class, which was fine when there was only one hypervisor, but made it
difficult to add support for per-host/multiple hypervisors.

Now, there's a 1-to-many relationship between the Generator
(BeakerHostGenerator::Generator) and the
Hypervisors (BeakerHostGenerator::Hypervisor).

The giant map of OSINFO data that was previously in the
'data/vmpooler.rb' has been promoted and moved into data.rb as the
`osinfo` module function. The parts specific to the VMPooler hypervisor
have been nested under submaps keyed by the name of the hypervisor,
`:vmpooler`.

Adding support for a new hypervisor now requires implementing
BeakerHostGenerator::Hypervisor::Interface, and adding any appropriate
platform data as a submap to the OSINFO map in data.rb, keyed under a
symbol named after the new hypervisor (e.g. `:my_hypervisor`).

The module function `BeakerHostGenerator::Data.get_platform_info` can
then be used when implementing the hypervisor to extract the relevant
platform data under the key `:my_hypervisor`.
```
### <a name = "0.5.0">0.5.0 - 31 Mar, 2016 (fa3ae0c8)

* (HISTORY) update beaker-hostgenerator history for gem release 0.5.0 (fa3ae0c8)

* (GEM) update beaker-hostgenerator version to 0.5.0 (36291ea6)

* (MAINT) Update changelog for pending release. (5b2e75bf)

* Merge pull request #26 from puppetlabs/qeng-3489 (2b9b0ad4)


```
Merge pull request #26 from puppetlabs/qeng-3489

(QENG-3489) Add Ubuntu 16.04 to beaker host generator data.
```
* (MAINT) Fix borked test fixtures. (e5d60be4)

* (QENG-3489) Add Ubuntu 16.04 to vmpooler platform data. (23e10232)

* Merge pull request #25 from LuvCurves/remove_cisco_xr_ssh_user (50016446)


```
Merge pull request #25 from LuvCurves/remove_cisco_xr_ssh_user

(maint) Remove ssh user from Cisco XR platform.
```
* (maint) Remove ssh user from Cisco XR platform. (79fcd1cf)

* Merge pull request #24 from LuvCurves/BKR-706 (0c7c31cf)


```
Merge pull request #24 from LuvCurves/BKR-706

(BKR-706) Update Cisco platforms to match beaker
```
* (maint) Changed names based on Cisco recommendation (7b88434c)

* (BKR-706) Update Cisco platforms to match beaker (7c44bb80)

### <a name = "0.4.0">0.4.0 - 10 Feb, 2016 (dc333b1c)

* (HISTORY) update beaker-hostgenerator history for gem release 0.4.0 (dc333b1c)

* (GEM) update beaker-hostgenerator version to 0.4.0 (fe10edc1)

* (MAINT) Remove hard-coded gemspec date. (4770b013)

* Merge pull request #23 from puppetlabs/maint (f8b77852)


```
Merge pull request #23 from puppetlabs/maint

(QENG-3466) Fix --list bug and write tests to prevent recurrences.
```
* (MAINT) s/Errors/Exceptions/ in bin directory (b8b68c60)

* (MAINT) Better semantics for exception naming. (d0129893)

* (MAINT) Actually add new test. (f80192f3)

* (MAINT) Be more explicit in CHANGELOG (0a39fb6b)

* (MAINT) Write test for safe early exit behavior. (34866de1)


```
(MAINT) Write test for safe early exit behavior.

Specifically, ensure that when passed the "--list" options,
BeakerHostGenerator::CLI.initialize will raise the
BeakerHostGenerator::Errors::SafeEarlyExit exception which is intended to be
ignored by the script calling BeakerHostGenerator::CLI.initialize
```
* (MAINT) Update CHANGELOG (bb52432b)

* (MAINT) Write tests to protect --list CLI behavior. (e523773f)

* (MAINT) Don't call 'exit' in BeakerHostGenerator::CLI class. (e3bac654)

* (MAINT) Fix bug introduced by eecc04c (865b04c2)

* Merge pull request #21 from puppetlabs/qeng-3370 (45bf2295)


```
Merge pull request #21 from puppetlabs/qeng-3370

(QENG-3370) Add pe_* value CLI override options.
```
* (QENG-3370) Use mixins instead of module method references. (eecc04c8)

* (QENG-3370) Address PR feedback. (19cc3a9b)

* (QENG-3370) Fix grammar no no. (4d7d5db3)

* Revert "(QENG-3370) Add .projectile (emacs plugin) path exclusion." (1db7dfcc)


```
Revert "(QENG-3370) Add .projectile (emacs plugin) path exclusion."

This reverts commit 3dd4eb3a5488b55f6aae1d65db43e84c7c0ff625.
```
* (QENG-3370) Fix fixtures after merging cisco changes from master branch. (e1c65ffc)

* Merge remote-tracking branch 'origin/master' into qeng-3370 (8559505b)

* (QENG-3370) Fix module constant initialization bug. (aa3e08cd)


```
(QENG-3370) Fix module constant initialization bug.

Similar to the BeakerHostGenerator::Data::Vmpooler data initialization bug, this
is something that would not typically show up during normal command line usage
of beaker-hostgenerator because at that time there is typically only one
reference made to the BeakerHostGenerator::Utils module constant. However during
test fixture generation and rspec tests the modules were only loaded once so
there was only one attempt to read in environment variables which led to
inconsisten results depending on the order in which the fixtures were
generated/tested.
```
* (QENG-3370) Fix major bug in BeakerHostGenerator::Data::Vmpooler (f3359c8f)


```
(QENG-3370) Fix major bug in BeakerHostGenerator::Data::Vmpooler

Since the OSINFO and OSINFO_BHGv1 module constants are only initialized once
(during library load), do not refer directly to them using reference variables.
Instead, initialize the osinfo variable directly on each call of get_osinfo and
merge in the module constants as appropriate based on the given
beaker-hostenerator version integer.

This bug never came up during normal command-line usage of beaker-hostgenerator
because get_osinfo would never be expected to be called with both bhg_version=0
and bhg_version=1. However, it came up both during generation of test fixtures
and validation of those test fixtures in rspec since the module is only loaded
once which led to the mutated value of the OSINFO module constant to persist
across all initializations of the BeakerHostGenerator::CLI class.
```
* (QENG-3370) Generate test cases for pe_{family,version} variable combinations. (99965b3f)

* (QENG-3370) Minor cleanup of new rspec test. (e9a77bb5)

* (QENG-3370) Use fixtures in rspec tests instead of minitest. (b401574d)


```
(QENG-3370) Use fixtures in rspec tests instead of minitest.

This makes it possible to treat each individual fixture its own test case which
improves the reporting and ensures that all fixtures are tested even if some
fail.

Using a loop containing an assertion in minitest did not work for this purpose
because a failed assertion caused the loop to break prematurely; it probably
would have been possible to catch whatever the exception was and continue the
loop but whatever. I already did this.
```
* (QENG-3370) Rename options_string to arguments_string. (c6507fd4)

* (QENG-3370) Add documentation for test fixtures. (b6712a9b)

* (QENG-3370) Make it a little easier to generate fixtures. (a829a425)


```
(QENG-3370) Make it a little easier to generate fixtures.

* Move FixtureGenerator class into test/utils/generator_helpers.rb
* Create generate:test Rake task
```
* (QENG-3370) Add assert_equal mismatch message. (11cbba23)

* (QENG-3370) Add .projectile (emacs plugin) path exclusion. (3dd4eb3a)

* (QENG-3370) Use YAML.load_file method. (0b353986)

* (QENG-3370) Don't use minitest to generate fixtures. (6c3a890f)

* (QENG-3370) Generate various option fixtures. (71e4efca)

* (QENG-3370) Add some fixtures and a test case to iterate over them. (722abcd5)

* (QENG-3370) Use enumerators to produce more diverse combinations of host roles. (2f913aec)

* (QENG-3370) Move helper methods into helper module. (f4fd1cf5)


```
(QENG-3370) Move helper methods into helper module.

Unclutters the fixture generator class and maintains distinction between test
and helper methods.
```
* (QENG-3370) Create common method for generating options-based fixtures. (6be93ddc)


```
(QENG-3370) Create common method for generating options-based fixtures.

This will make it easier to generate many many fixtures.
```
* (QENG-3370) Add janky fixture generator. (88ac0341)


```
(QENG-3370) Add janky fixture generator.

This script allows one to generate test fixtures using beaker-hostgenerator
itself. Yay. The generated directory structure could use some more thought.
```
* (QENG-3370) Move GeneratorTestHelpers into its own file. (f7d3f996)

* (QENG-3370) Use BeakerHostGenerator::CLI directly. (45a2f7e4)


```
(QENG-3370) Use BeakerHostGenerator::CLI directly.

This may be necessary to ensure coverage checks can work correctly. Also, it
makes sense to test at this since I know of at least one project that is doing
something similar.

Not so sure about the way this is handling stderr though--just trying to avoid
polluting the minitest console output.
```
* (QENG-3770) Add GeneratorTestHelpers and default options test for test class. (388867d1)

* (QENG-3770) Stub out minitest for Generator class. (3af5796d)

* (QENG-3770) Get test:spec rake task to run minitest also. (436bb778)

* (QENG-3370) Add pe_* value CLI override options. (e321afc3)

### <a name = "0.3.3">0.3.3 - 3 Feb, 2016 (41051da9)

* (HISTORY) update beaker-hostgenerator history for gem release 0.3.3 (41051da9)

* (GEM) update beaker-hostgenerator version to 0.3.3 (34f5cee5)

* Merge pull request #20 from LuvCurves/master (9615ac0c)


```
Merge pull request #20 from LuvCurves/master

(maint) Add better support for Cisco platforms
```
* (MAINT) Update changelog. (bd675277)

* (maint) Add better support for Cisco platforms (f4ca866a)

### <a name = "0.3.2">0.3.2 - 28 Jan, 2016 (299df8ec)

* (HISTORY) update beaker-hostgenerator history for gem release 0.3.2 (299df8ec)

* (GEM) update beaker-hostgenerator version to 0.3.2 (1b73712d)

* Merge pull request #22 from Iristyle/update-win-10-platforms (b181cd18)


```
Merge pull request #22 from Iristyle/update-win-10-platforms

(maint) Update Windows 10 platform names
```
* (maint) Update Windows 10 platform names (27a26440)


```
(maint) Update Windows 10 platform names

 - Previous convention for Windows platforms is to always end in a -32
   or -64.  There are some tests that rely on this naming scheme to
   properly identify a 32-bit or 64-bit OS.

   For instance, a Puppet acceptance test relies on that convention when
   detecting the location of binaries per:

   https://github.com/puppetlabs/puppet/blob/master/acceptance/tests/ensure_puppet-agent_paths.rb#L140-L143

   Original commit that introduced these was
   3d1be3833b0dd95d508d89ecbe76464524f578c3
```
### <a name = "0.3.1">0.3.1 - 30 Dec, 2015 (7a3f10ca)

* (HISTORY) update beaker-hostgenerator history for gem release 0.3.1 (7a3f10ca)

* (GEM) update beaker-hostgenerator version to 0.3.1 (8f469a6f)

* Merge pull request #19 from puppetlabs/issue/qeng-3335-centos-only (a478482a)


```
Merge pull request #19 from puppetlabs/issue/qeng-3335-centos-only

(QENG-3335) Restrict osinfo v1 to centos only changes
```
* (QENG-3335) Restrict osinfo v1 to centos only changes (851f1b40)


```
(QENG-3335) Restrict osinfo v1 to centos only changes

See https://tickets.puppetlabs.com/browse/BKR-662 for backstory.
```
### <a name = "0.3.0">0.3.0 - 30 Dec, 2015 (4b03eaf4)

* (HISTORY) update beaker-hostgenerator history for gem release 0.3.0 (4b03eaf4)

* (GEM) update beaker-hostgenerator version to 0.3.0 (5bc2d40b)

* Merge pull request #18 from puppetlabs/qeng-3335 (323ed794)


```
Merge pull request #18 from puppetlabs/qeng-3335

(QENG-3335) Don't identify centos as el in 'platform'
```
* (QENG-3335) Fix typo in osinfo version deprecation message. (b4903f78)

* (QENG-3335) Fix the OSINFO deprecation warning. (e364bd97)


```
(QENG-3335) Fix the OSINFO deprecation warning.

Assignment to the "warning" variable was incorrect, also it appears that one
cannot print to STDERR within the OptionParser.new block...
```
* (QENG-3335) Add OSINFO v0 deprecation warning. (4336126a)

* (QENG-3335) s/bgh/bhg/ s/BGH/BHG/ (bfb95f05)

* (QENG-3335) Cast osinfo-version to integer. (4e9d8088)

* (QENG-3335) Don't forget to use the bgh_version. (c9dec1b7)

* (QENG-3335) Actually, don't change the original datastructure name. (e1f4cd4a)

* (QENG-3335) Actually, use '--osinfo-version' flag instead. (391fdd68)

* (QENG-3335) Add 'enable-unambiguous-platform-names' flag. (888f8d40)

* (QENG-3335) Don't identify centos as el in 'platform' (520028e2)

* Merge pull request #17 from puppetlabs/maint (3fc629e4)


```
Merge pull request #17 from puppetlabs/maint

(MAINT) Update Changelog for recent releases.
```
* (MAINT) Update Changelog for recent releases. (2ae32038)

### <a name = "0.2.0">0.2.0 - 22 Dec, 2015 (dfa33e5f)

* (HISTORY) update beaker-hostgenerator history for gem release 0.2.0 (dfa33e5f)

* (GEM) update beaker-hostgenerator version to 0.2.0 (1194df93)

* Merge pull request #15 from puppetlabs/(QENG-3301)-Add-support-for-Cumulus-Linux (9a8e655c)


```
Merge pull request #15 from puppetlabs/(QENG-3301)-Add-support-for-Cumulus-Linux

(QENG-3301) Add support for Cumulus Linux
```
* Merge pull request #16 from puppetlabs/maint (982e7deb)


```
Merge pull request #16 from puppetlabs/maint

(MAINT) Fix arista4 spec string.
```
* Merge pull request #14 from puppetlabs/(QENG-3308)(QENG-3309)-Add-support-for-Cisco-platforms (bb18139d)


```
Merge pull request #14 from puppetlabs/(QENG-3308)(QENG-3309)-Add-support-for-Cisco-platforms

(QENG-3308)(QENG-3309) Add support for Cisco platforms
```
* (MAINT) Fix arista4 spec string. (6a7715a0)

* (QENG-3308) (QENG-3309) Add hardware platform signifier. (29bf775c)

* Updated platform strings based on comments. (6727a9dd)

* (QENG-3301) Add support for Cumulus Linux (a1a96d5a)

* (QENG-3308)(QENG-3309) Add support for Cisco platforms (c7cfbaa0)

* Merge pull request #12 from puppetlabs/maint (084ae0cf)


```
Merge pull request #12 from puppetlabs/maint

Revert "(QENG-3309) Add support for Cisco wrlinux-7"
```
* Revert "(QENG-3309) Add support for Cisco wrlinux-7" (3693133f)


```
Revert "(QENG-3309) Add support for Cisco wrlinux-7"

This reverts commit 3e36da18e7bfeec2fa92295fa5f9959d45611eb4.
```
* Merge pull request #11 from puppetlabs/(QENG-3309)-Add-support-for-Cisco-wrlinux-7 (0fdf80ec)


```
Merge pull request #11 from puppetlabs/(QENG-3309)-Add-support-for-Cisco-wrlinux-7

(QENG-3309) Add support for Cisco wrlinux-7
```
* (QENG-3309) Add support for Cisco wrlinux-7 (3e36da18)

### <a name = "0.1.0">0.1.0 - 21 Dec, 2015 (474f4ccb)

* (HISTORY) update beaker-hostgenerator history for gem release 0.1.0 (474f4ccb)

* (GEM) update beaker-hostgenerator version to 0.1.0 (13477a89)

* Merge pull request #10 from joshcooper/ticket/master/QENG-3275-32bit-puppet-64bit-windows (b059a8c6)


```
Merge pull request #10 from joshcooper/ticket/master/QENG-3275-32bit-puppet-64bit-windows

(QENG-3275) Add support for 32-bit puppet on 64-bit windows
```
* (QENG-3275) Ensure ruby_arch matches install_32 (00b625e0)


```
(QENG-3275) Ensure ruby_arch matches install_32

Previously, if then `pe_use_win32` environment variable was set, then
the resulting host config for 64-bit windows OS's, would contain
`ruby_arch: x64`, which contradicted `install_32: true`.

This commit ensures `ruby_arch: x86` in this particular case so that it
is consistent with `install_32: true`.
```
* Merge pull request #8 from puppetlabs/(QENG-3307)-Add-support-for-Arista (a9ffbade)


```
Merge pull request #8 from puppetlabs/(QENG-3307)-Add-support-for-Arista

Added Arista support
```
* Update vmpooler.rb (a72bb36f)

* Added Arista support (cf70e0ca)

* Merge pull request #7 from puppetlabs/qeng-3181 (ffd8b2d0)


```
Merge pull request #7 from puppetlabs/qeng-3181

(QENG-3181) Add a 'genconfig2' command line tool with deprecation war…
```
* Merge pull request #6 from puppetlabs/qeng-2438 (a98bc8c6)


```
Merge pull request #6 from puppetlabs/qeng-2438

(QENG-2438) Improve beaker-hostgenerator documentation.
```
* (QENG-2438) Fix typo in CONTRIBUTING.md (c58e8fee)

* (QENG-3275) Add hybrid Windows host configs for 32-bit puppet (f113ba1c)


```
(QENG-3275) Add hybrid Windows host configs for 32-bit puppet

Add host configs for specifying 32-bit puppet on 64-bit Windows, e.g.

    bundle exec beaker-hostgenerator windows2012r2-6432a
    ---
    HOSTS:
      windows2012r2-6432-1:
        ...
        platform: windows-2012r2-64
        template: win-2012r2-x86_64
        ruby_arch: x86
        roles:
        - agent

Updates `--list` update to describe 64, 32, and 6432 bits.
```
* (QENG-3275) Default ruby_arch based on Windows arch (6b6c3595)


```
(QENG-3275) Default ruby_arch based on Windows arch

Previously, Windows host configs did not contain `ruby_arch`, which
puppet, facter, and pxp-agent rely on during acceptance tests to
detect which version of ruby is running, as we support running either
32 or 64-bit puppet on 64-bit Windows.

This commit ensures `ruby_arch` is set to x64 for 64-bit Windows, and
x86 for 32-bit Windows.
```
* (QENG-3181) Add a 'genconfig2' command line tool with deprecation warning. (0adfab77)

* (QENG-2438) Add a CONTRIBUTING.md. (d1e8a747)


```
(QENG-2438) Add a CONTRIBUTING.md.

Heavily modified version of Beaker's CONTRIBUTING.md
```
* (QENG-2438) Improve beaker-hostgenerator documentation. (41b33040)

* Merge pull request #5 from joshcooper/ticket/master/QENG-3267-call-cli-programmatically (4dace64a)


```
Merge pull request #5 from joshcooper/ticket/master/QENG-3267-call-cli-programmatically

(QENG-3267) Allow CLI to be called programmatically
```
* Merge pull request #4 from joshcooper/ticket/maint/genconfig-typo (a69dc2b8)


```
Merge pull request #4 from joshcooper/ticket/maint/genconfig-typo

(maint) Refer to new Beaker::Host::Generator::Data constant
```
* Merge pull request #3 from puppetlabs/copy-edit-usage-docstring (b7c4f26e)


```
Merge pull request #3 from puppetlabs/copy-edit-usage-docstring

Copy edit usage docstring
```
* Merge pull request #2 from puppetlabs/readme-typo-fixed (c691c650)


```
Merge pull request #2 from puppetlabs/readme-typo-fixed

README typo fixed
```
* (QENG-3267) Add an execute method for programmatic execution (124e6504)


```
(QENG-3267) Add an execute method for programmatic execution

Previously, it was not possible to execute the CLI and get back the
output as a string.

This commit adds an `execute` method that does that, and modifies
`execute!` to print what `execute` returns, as it did before.
```
* (QENG-3267) Allow CLI to be called programmatically (b571680d)


```
(QENG-3267) Allow CLI to be called programmatically

Previously, the CLI class relied on the global ARGV which prevented
the CLI from being called programmatically.

This commit changes the initialize method to take an optional array of
arguments. If none are provided, we use the global ARGV as we did
before, although we make a duplicate of it, since we later mutate it,
e.g. pushing "--help".
```
* (QENG-3267) Reindent leading whitespace (0fcf55c5)


```
(QENG-3267) Reindent leading whitespace

The previous commit eliminated two levels of indentation. This commit
only reindents eliminating leading whitespace.
```
* (QENG-3267) Rename Beaker::Host::Generator to BeakerHostGenerator (19455f66)


```
(QENG-3267) Rename Beaker::Host::Generator to BeakerHostGenerator

Previously, we were using the Beaker::Host::Generator namespace, where
Beaker::Host is a module, but beaker defines Beaker::Host to be a
class, so you could not require both beaker and beaker-hostgenerator.

This commit renames the module namespace to BeakerHostGenerator so
that it cannot collide with Beaker.

This is a backwards incompatible change if anyone is programmatically
calling Beaker::Host::Generator, but I don't think anyone is.
```
* (maint) Refer to new Beaker::Host::Generator::Data constant (082fe71c)


```
(maint) Refer to new Beaker::Host::Generator::Data constant

Previously, trying to call `beaker-hostgenerator --list` would result
in:

    uninitialized constant Beaker::Host::Generator::Utils::GenConfig (NameError)

This commit updates the code to use the new constant name.
```
* Copy edit usage docstring (98a5e0fe)

* README typo fixed (ba88e07e)

### 0.0.1 - 7 Oct, 2015 (d99251e6)

* Initial release.
