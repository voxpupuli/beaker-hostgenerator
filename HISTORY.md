# default - History
## Tags
* [LATEST - 22 Dec, 2015 (1194df93)](#LATEST)
* [0.1.0 - 21 Dec, 2015 (474f4ccb)](#0.1.0)
* [0.0.1 - 7 Oct, 2015 (d99251e6)](#0.0.1)

## Details
### <a name = "LATEST">LATEST - 22 Dec, 2015 (1194df93)

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

### <a name = "0.0.1">0.0.1 - 7 Oct, 2015 (d99251e6)

* Initial release.
