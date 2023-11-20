module BeakerHostGenerator
  # Contains all the platform information that ends up in the generated hosts
  # configuration. This includes the various OS-specific platform
  # configuration, and PE-specific installation & upgrade configuration.
  #
  # Any data used by any hypervisor or any other abstraction should be defined
  # in this module, likely in the `osinfo` hash. The hypervisor implementation
  # must then use the provided module functions (likely `get_platform_info`) to
  # extract the relevant portions of the `osinfo` data.
  #
  # This module is intended to be used by either directly accessing the static
  # functions like `BeakerHostGenerator::Data.<function>()` or as a mixin via
  # `include BeakerHostGenerator::Data` and then `<function>()`.
  module Data
    module_function

    MAIN_PE_VERSION = '2023.0'
    PE_TARBALL_SERVER = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local'

    def pe_version
      ENV.fetch('pe_version', nil)
    end

    def pe_upgrade_version
      ENV.fetch('pe_upgrade_version', nil)
    end

    def pe_dir(version)
      return if version.nil? || version.empty?

      base_regex = '(\A\d+\.\d+)\.\d+'
      source = case version
               when /#{base_regex}\Z/
                 "#{PE_TARBALL_SERVER}/archives/releases/#{version}/"
               when /#{base_regex}-rc\d+\Z/
                 "#{PE_TARBALL_SERVER}/archives/internal/%s/"
               when /#{base_regex}-.*(PEZ|pez)_.*/
                 "#{PE_TARBALL_SERVER}/%s/feature/ci-ready"
               when /#{base_regex}-.*/
                 "#{PE_TARBALL_SERVER}/%s/ci-ready"
               else
                 ''
               end

      pe_family = ::Regexp.last_match(1)
      gem_version = Gem::Version.new(pe_family)
      pe_branch = if gem_version < Gem::Version.new("#{MAIN_PE_VERSION}") || version =~ /#{base_regex}-rc\d+\Z/
                    pe_family
                  else
                    'main'
                  end

      format(source, ("#{pe_branch}" || ''))
    end

    PE_USE_WIN32 = ENV.fetch('pe_use_win32', nil)

    BASE_CONFIG = {
      'HOSTS' => {},
      'CONFIG' => {},
    }

    def base_host_config(options)
      {
        'pe_dir' => options[:pe_dir] || pe_dir(pe_version),
        'pe_ver' => options[:pe_ver] || pe_version,
        'pe_upgrade_dir' => options[:pe_upgrade_dir] || pe_dir(pe_upgrade_version),
        'pe_upgrade_ver' => options[:pe_upgrade_ver] || pe_upgrade_version,
      }.reject { |_key, value| value.nil? }
    end

    # This is where all the information for all platforms lives, irrespective
    # of the hypervisor(s).
    # This hash contains every OS that BHG supports as keys, and the values are
    # hashes that contain hypervisor-specific data about that OS.
    # Every OS also has a special "general" section for data that should always
    # be included regardless of the hypervisor.
    # Hypervisor implementations will then grab specific bits of data out of
    # this hash and combine them to produce the generated hosts output.
    def osinfo
      result = {}

      generate_osinfo do |name, platform|
        result[name] = {
          general: {
            'platform' => platform,
          },
        }
      end

      result.merge!({
                      'aix71-POWER' => {
                        general: {
                          'platform' => 'aix-7.1-power',
                        },
                        abs: {
                          'template' => 'aix-7.1-power',
                        },
                      },
                      'aix72-POWER' => {
                        general: {
                          'platform' => 'aix-7.2-power',
                          'packaging_platform' => 'aix-7.1-power',
                        },
                        abs: {
                          'template' => 'aix-7.2-power',
                        },
                      },
                      'amazon6-64' => {
                        general: {
                          'platform' => 'el-6-x86_64',
                        },
                        abs: {
                          'template' => 'amazon-6-x86_64',
                        },
                      },
                      'amazon7-64' => {
                        general: {
                          'platform' => 'el-7-x86_64',
                        },
                        abs: {
                          'template' => 'amazon-7-x86_64',
                        },
                      },
                      'amazon7-ARM64' => {
                        general: {
                          'platform' => 'el-7-aarch64',
                        },
                        abs: {
                          'template' => 'amazon-7-arm64',
                        },
                      },
                      'archlinuxrolling-64' => {
                        general: {
                          'platform' => 'archlinux-rolling-x64',
                        },
                        vagrant: {
                          'box' => 'archlinux/archlinux',
                        },
                        docker: {
                          'image' => 'archlinux/archlinux',
                        },
                      },
                      'centos7-64' => {
                        general: {
                          'platform' => 'el-7-x86_64',
                        },
                      },
                      'centos8-64' => {
                        general: {
                          'platform' => 'el-8-x86_64',
                        },
                        vagrant: {
                          'box' => 'centos/stream8',
                          'box_url' => 'https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-Vagrant-8-20230501.0.x86_64.vagrant-libvirt.box',
                        },
                      },
                      'centos9-64' => {
                        general: {
                          'platform' => 'el-9-x86_64',
                        },
                        vagrant: {
                          'box' => 'centos/stream9',
                          'box_url' => 'https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-Vagrant-9-20230410.0.x86_64.vagrant-libvirt.box',
                        },
                      },
                      'debian10-64' => {
                        general: {
                          'platform' => 'debian-10-amd64',
                        },
                        vagrant: {
                          'box' => 'debian/buster64',
                        },
                      },
                      'debian10-32' => {
                        general: {
                          'platform' => 'debian-10-i386',
                        },
                      },
                      'debian11-64' => {
                        general: {
                          'platform' => 'debian-11-amd64',
                        },
                        vagrant: {
                          'box' => 'debian/bullseye64',
                        },
                      },
                      'debian11-AARCH64' => {
                        general: {
                          'platform' => 'debian-11-aarch64',
                        },
                      },
                      'debian12-64' => {
                        general: {
                          'platform' => 'debian-12-amd64',
                        },
                        vagrant: {
                          'box' => 'debian/bookworm64',
                        },
                      },
                      'debian12-AARCH64' => {
                        general: {
                          'platform' => 'debian-12-aarch64',
                        },
                      },
                      'panos61-64' => {
                        general: {
                          'platform' => 'palo-alto-6.1.0-x86_64',
                        },
                      },
                      'panos71-64' => {
                        general: {
                          'platform' => 'palo-alto-7.1.0-x86_64',
                        },
                      },
                      'panos81-64' => {
                        general: {
                          'platform' => 'palo-alto-8.1.0-x86_64',
                        },
                      },
                      'osx1015-64' => {
                        general: {
                          'platform' => 'osx-10.15-x86_64',
                        },
                        vmpooler: {
                          'template' => 'osx-1015-x86_64',
                        },
                      },
                      'osx11-64' => {
                        general: {
                          'platform' => 'osx-11-x86_64',
                        },
                        vmpooler: {
                          'template' => 'macos-112-x86_64',
                        },
                      },
                      'osx11-ARM64' => {
                        general: {
                          'platform' => 'osx-11-arm64',
                        },
                        vmpooler: {
                          'template' => 'macos-11-arm64',
                        },
                      },
                      'osx12-64' => {
                        general: {
                          'platform' => 'osx-12-x86_64',
                        },
                        vmpooler: {
                          'template' => 'macos-12-x86_64',
                        },
                      },
                      'osx12-ARM64' => {
                        general: {
                          'platform' => 'osx-12-arm64',
                        },
                        vmpooler: {
                          'template' => 'macos-12-arm64',
                        },
                      },
                      'osx13-64' => {
                        general: {
                          'platform' => 'osx-13-x86_64',
                        },
                        vmpooler: {
                          'template' => 'macos-13-x86_64',
                        },
                      },
                      'osx13-ARM64' => {
                        general: {
                          'platform' => 'osx-13-arm64',
                        },
                        vmpooler: {
                          'template' => 'macos-13-arm64',
                        },
                      },
                      'redhat6-32' => {
                        general: {
                          'platform' => 'el-6-i386',
                        },
                        vmpooler: {
                          'template' => 'redhat-6-i386',
                        },
                      },
                      'redhat6-64' => {
                        general: {
                          'platform' => 'el-6-x86_64',
                        },
                        vmpooler: {
                          'template' => 'redhat-6-x86_64',
                        },
                      },
                      'redhat6-S390X' => {
                        general: {
                          'platform' => 'el-6-s390x',
                        },
                      },
                      'redhat7-64' => {
                        general: {
                          'platform' => 'el-7-x86_64',
                        },
                      },
                      'redhatfips7-64' => {
                        general: {
                          'platform' => 'el-7-x86_64',
                          'packaging_platform' => 'redhatfips-7-x86_64',
                        },
                        vmpooler: {
                          'template' => 'redhat-fips-7-x86_64',
                        },
                      },
                      'redhat7-POWER' => {
                        general: {
                          'platform' => 'el-7-ppc64le',
                        },
                        abs: {
                          'template' => 'redhat-7.3-power8',
                        },
                      },
                      'redhat7-S390X' => {
                        general: {
                          'platform' => 'el-7-s390x',
                        },
                      },
                      'redhat7-AARCH64' => {
                        general: {
                          'platform' => 'el-7-aarch64',
                        },
                        abs: {
                          'template' => 'centos-7-arm64',
                        },
                        vmpooler: {
                          'template' => 'redhat-7-x86_64',
                        },
                      },
                      'redhat8-64' => {
                        general: {
                          'platform' => 'el-8-x86_64',
                        },
                      },
                      'redhatfips8-64' => {
                        general: {
                          'platform' => 'el-8-x86_64',
                          'packaging_platform' => 'redhatfips-8-x86_64',
                        },
                        vmpooler: {
                          'template' => 'redhat-fips-8-x86_64',
                        },
                      },
                      'redhat8-AARCH64' => {
                        general: {
                          'platform' => 'el-8-aarch64',
                        },
                        abs: {
                          'template' => 'redhat-8-arm64',
                        },
                        vmpooler: {
                          'template' => 'redhat-8-x86_64',
                        },
                      },
                      'redhat8-POWER' => {
                        general: {
                          'platform' => 'el-8-ppc64le',
                        },
                        abs: {
                          'template' => 'redhat-8-power8',
                        },
                      },
                      'redhat9-64' => {
                        general: {
                          'platform' => 'el-9-x86_64',
                        },
                      },
                      'redhat9-AARCH64' => {
                        general: {
                          'platform' => 'el-9-aarch64',
                        },
                        abs: {
                          'template' => 'redhat-9-arm64',
                        },
                        vmpooler: {
                          'template' => 'redhat-9-arm64',
                        },
                      },
                      'redhat9-POWER' => {
                        general: {
                          'platform' => 'el-9-ppc64le',
                        },
                        abs: {
                          'template' => 'redhat-9-power',
                        },
                      },
                      'sles11-32' => {
                        general: {
                          'platform' => 'sles-11-i386',
                        },
                        vmpooler: {
                          'template' => 'sles-11-i386',
                        },
                      },
                      'sles11-64' => {
                        general: {
                          'platform' => 'sles-11-x86_64',
                        },
                        vmpooler: {
                          'template' => 'sles-11-x86_64',
                        },
                      },
                      'sles11-S390X' => {
                        general: {
                          'platform' => 'sles-11-s390x',
                        },
                      },
                      'sles12-64' => {
                        general: {
                          'platform' => 'sles-12-x86_64',
                        },
                        vmpooler: {
                          'template' => 'sles-12-x86_64',
                        },
                      },
                      'sles12-S390X' => {
                        general: {
                          'platform' => 'sles-12-s390x',
                        },
                      },
                      'sles12-POWER' => {
                        general: {
                          'platform' => 'sles-12-ppc64le',
                        },
                        abs: {
                          'template' => 'sles-12-power8',
                        },
                      },
                      'sles15-64' => {
                        general: {
                          'platform' => 'sles-15-x86_64',
                        },
                        vmpooler: {
                          'template' => 'sles-15-x86_64',
                        },
                      },
                      'solaris10-32' => {
                        general: {
                          'platform' => 'solaris-10-i386',
                        },
                        vmpooler: {
                          'template' => 'solaris-10-x86_64',
                        },
                      },
                      'solaris10-64' => {
                        general: {
                          'platform' => 'solaris-10-i386',
                        },
                        vmpooler: {
                          'template' => 'solaris-10-x86_64',
                        },
                      },
                      'solaris10-SPARC' => {
                        general: {
                          'platform' => 'solaris-10-sparc',
                        },
                        abs: {
                          'template' => 'solaris-10-sparc',
                        },
                      },
                      'solaris11-32' => {
                        general: {
                          'platform' => 'solaris-11-i386',
                        },
                        vmpooler: {
                          'template' => 'solaris-11-x86_64',
                        },
                      },
                      'solaris11-64' => {
                        general: {
                          'platform' => 'solaris-11-i386',
                        },
                        vmpooler: {
                          'template' => 'solaris-11-x86_64',
                        },
                      },
                      'solaris11-SPARC' => {
                        general: {
                          'platform' => 'solaris-11-sparc',
                        },
                        abs: {
                          'template' => 'solaris-11-sparc',
                        },
                      },
                      'solaris112-32' => {
                        general: {
                          'platform' => 'solaris-11.2-i386',
                          'packaging_platform' => 'solaris-11-i386',
                        },
                        vmpooler: {
                          'template' => 'solaris-112-x86_64',
                        },
                      },
                      'solaris112-64' => {
                        general: {
                          'platform' => 'solaris-11.2-i386',
                          'packaging_platform' => 'solaris-11-i386',
                        },
                        vmpooler: {
                          'template' => 'solaris-112-x86_64',
                        },
                      },
                      'solaris114-32' => {
                        general: {
                          'platform' => 'solaris-11.4-i386',
                          'packaging_platform' => 'solaris-11-i386',
                        },
                        vmpooler: {
                          'template' => 'solaris-114-x86_64',
                        },
                      },
                      'solaris114-64' => {
                        general: {
                          'platform' => 'solaris-11.4-i386',
                          'packaging_platform' => 'solaris-11-i386',
                        },
                        vmpooler: {
                          'template' => 'solaris-114-x86_64',
                        },
                      },
                      'vro6-64' => {
                        general: {
                          'platform' => 'sles-11-x86_64',
                        },
                        vmpooler: {
                          'template' => 'vro-6-x86_64',
                        },
                      },
                      'vro7-64' => {
                        general: {
                          'platform' => 'sles-11-x86_64',
                        },
                        vmpooler: {
                          'template' => 'vro-7-x86_64',
                        },
                      },
                      'vro71-64' => {
                        general: {
                          'platform' => 'sles-11-x86_64',
                        },
                        vmpooler: {
                          'template' => 'vro-71-x86_64',
                        },
                      },
                      'vro73-64' => {
                        general: {
                          'platform' => 'sles-11-x86_64',
                        },
                        vmpooler: {
                          'template' => 'vro-73-x86_64',
                        },
                      },
                      'vro74-64' => {
                        general: {
                          'platform' => 'sles-11-x86_64',
                        },
                        vmpooler: {
                          'template' => 'vro-74-x86_64',
                        },
                      },
                      'windows2008-64' => {
                        general: {
                          'platform' => 'windows-2008-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2008-x86_64',
                        },
                      },
                      'windows2008-6432' => {
                        general: {
                          'platform' => 'windows-2008-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2008-x86_64',
                        },
                      },
                      'windows2008r2-64' => {
                        general: {
                          'platform' => 'windows-2008r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2008r2-x86_64',
                        },
                      },
                      'windows2008r2-6432' => {
                        general: {
                          'platform' => 'windows-2008r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2008r2-x86_64',
                        },
                      },
                      'windows2012-64' => {
                        general: {
                          'platform' => 'windows-2012-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2012-x86_64',
                        },
                      },
                      'windows2012-6432' => {
                        general: {
                          'platform' => 'windows-2012-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2012-x86_64',
                        },
                      },
                      'windows2012r2-64' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-x86_64',
                        },
                      },
                      'windowsfips2012r2-64' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windowsfips-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-fips-x86_64',
                        },
                      },
                      'windowsfips2012r2-6432' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windowsfips-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-fips-x86_64',
                        },
                      },
                      'windows2012r2-6432' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-x86_64',
                        },
                      },
                      'windows2012r2_wmf5-64' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-wmf5-x86_64',
                        },
                      },
                      'windows2012r2_ja-64' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-ja-x86_64',
                          'locale' => 'ja',
                        },
                      },
                      'windows2012r2_ja-6432' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-ja-x86_64',
                          'locale' => 'ja',
                        },
                      },
                      'windows2012r2_fr-64' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-fr-x86_64',
                          'user' => 'Administrateur',
                          'locale' => 'fr',
                        },
                      },
                      'windows2012r2_fr-6432' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-fr-x86_64',
                          'user' => 'Administrateur',
                          'locale' => 'fr',
                        },
                      },
                      'windows2012r2_core-64' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-core-x86_64',
                        },
                      },
                      'windows2012r2_core-6432' => {
                        general: {
                          'platform' => 'windows-2012r2-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2012r2-core-x86_64',
                        },
                      },
                      'windows2016-64' => {
                        general: {
                          'platform' => 'windows-2016-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2016-x86_64',
                        },
                      },
                      'windows2016-6432' => {
                        general: {
                          'platform' => 'windows-2016-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2016-x86_64',
                        },
                      },
                      'windows2016_core-64' => {
                        general: {
                          'platform' => 'windows-2016-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2016-core-x86_64',
                        },
                      },
                      'windows2016_core-6432' => {
                        general: {
                          'platform' => 'windows-2016-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2016-core-x86_64',
                        },
                      },
                      'windows2016_fr-64' => {
                        general: {
                          'platform' => 'windows-2016-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2016-fr-x86_64',
                          'user' => 'Administrateur',
                          'locale' => 'fr',
                        },
                      },
                      'windows2016_fr-6432' => {
                        general: {
                          'platform' => 'windows-2016-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2016-fr-x86_64',
                          'user' => 'Administrateur',
                          'locale' => 'fr',
                        },
                      },
                      'windows2019-64' => {
                        general: {
                          'platform' => 'windows-2019-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2019-x86_64',
                        },
                      },
                      'windows2019-6432' => {
                        general: {
                          'platform' => 'windows-2019-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2019-x86_64',
                        },
                      },
                      'windows2019_ja-64' => {
                        general: {
                          'platform' => 'windows-2019-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2019-ja-x86_64',
                          'locale' => 'ja',
                        },
                      },
                      'windows2019_ja-6432' => {
                        general: {
                          'platform' => 'windows-2019-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2019-ja-x86_64',
                          'locale' => 'ja',
                        },
                      },
                      'windows2019_fr-64' => {
                        general: {
                          'platform' => 'windows-2019-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2019-fr-x86_64',
                          'user' => 'Administrateur',
                          'locale' => 'fr',
                        },
                      },
                      'windows2019_fr-6432' => {
                        general: {
                          'platform' => 'windows-2019-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2019-fr-x86_64',
                          'user' => 'Administrateur',
                          'locale' => 'fr',
                        },
                      },
                      'windows2019_core-64' => {
                        general: {
                          'platform' => 'windows-2019-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2019-core-x86_64',
                        },
                      },
                      'windows2019_core-6432' => {
                        general: {
                          'platform' => 'windows-2019-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-2019-core-x86_64',
                        },
                      },
                      'windows2022-64' => {
                        general: {
                          'platform' => 'windows-2022-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-2022-x86_64',
                        },
                      },
                      'windows10ent-32' => {
                        general: {
                          'platform' => 'windows-10ent-32',
                          'packaging_platform' => 'windows-2012-x86',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-10-ent-i386',
                        },
                      },
                      'windows10ent-64' => {
                        general: {
                          'platform' => 'windows-10ent-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-10-ent-x86_64',
                        },
                      },
                      'windows10next-32' => {
                        general: {
                          'platform' => 'windows-10ent-32',
                          'packaging_platform' => 'windows-2012-x86',
                          'ruby_arch' => 'x86',
                        },
                        vmpooler: {
                          'template' => 'win-10-next-i386',
                        },
                      },
                      'windows10next-64' => {
                        general: {
                          'platform' => 'windows-10ent-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-10-next-x86_64',
                        },
                      },
                      'windows10pro-64' => {
                        general: {
                          'platform' => 'windows-10pro-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-10-pro-x86_64',
                        },
                      },
                      'windows10_1511-64' => {
                        general: {
                          'platform' => 'windows-10ent-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-10-1511-x86_64',
                        },
                      },
                      'windows10_1607-64' => {
                        general: {
                          'platform' => 'windows-10ent-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-10-1607-x86_64',
                        },
                      },
                      'windows10_1809-64' => {
                        general: {
                          'platform' => 'windows-10ent-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-10-1809-x86_64',
                        },
                      },
                      'windows11ent-64' => {
                        general: {
                          'platform' => 'windows-11ent-64',
                          'packaging_platform' => 'windows-2012-x64',
                          'ruby_arch' => 'x64',
                        },
                        vmpooler: {
                          'template' => 'win-11-ent-x86_64',
                        },
                      },
                    })

      result['archlinux-64'] = result['archlinuxrolling-64']
      result
    end

    def osinfo_bhgv1
      {
        'centos7-64' => {
          general: {
            'platform' => 'centos-7-x86_64',
          },
          vmpooler: {
            'template' => 'centos-7-x86_64',
          },
        },
      }
    end

    # Returns the map of OS info for the given version of this library.
    # The current version is always available as version 0 (zero).
    # Throws an exception if the version number is unrecognized.
    #
    # This is intended to be the primary access point for the OS info maps
    # defined in `osinfo`, `osinfo_bhgv1`, etc.
    #
    # See also `get_platforms`, `get_platform_info`, for common operations on
    # this OS info map.
    def get_osinfo(bhg_version)
      case bhg_version
      when 0
        {}.deeper_merge!(osinfo)
      when 1
        {}.deeper_merge!(osinfo).deeper_merge!(osinfo_bhgv1)
      else
        raise "Invalid beaker-hostgenerator version: #{bhg_version}"
      end
    end

    # Returns the list of platforms supported by the specified version of this
    # library. This list should be equal to the keys of the `get_osinfo` map
    # and is provided as a common convenience.
    def get_platforms(bhg_version)
      get_osinfo(bhg_version).keys
    end

    # Returns the fully parsed map of information of the specified OS platform
    # for the specified hypervisor. This map should be suitable for outputting
    # to the user as it will have the intermediate organizational branches of
    # the `get_osinfo` map removed.
    #
    # This is intended to be the primary way to access OS info from hypervisor
    # implementations when generating host definitions.
    #
    # @param [Integer] bhg_version The version of OS info to use.
    #
    # @param [String] platform The OS platform to access from the OS info map.
    #
    # @param [Symbol] hypervisor The symbol representing which hypervisor submap
    #                 to extract from the general OS info map.
    #
    # @example Getting CentOS 6 64-bit information for the VMPooler hypervisor
    #     Given the OS info map looks like:
    #         ...
    #         'centos9-64' => {
    #           :general => { 'platform' => 'el-9-x86_64' },
    #           :vmpooler => { 'template' => 'centos-9-x86_64' }
    #         }
    #         ...
    #
    #     Then get_platform_info(0, 'centos9-64', :vmpooler) returns:
    #         {
    #           'platform' => 'el-6-x86_64',
    #           'template' => 'centos-6-x86_64'
    #         }
    def get_platform_info(bhg_version, platform, hypervisor)
      info = get_osinfo(bhg_version)[platform]
      return {} unless info

      {}.deeper_merge!(info[:general]).deeper_merge!(info[hypervisor])
    end

    # @api private
    def generate_osinfo
      # AIX
      yield %w[aix73-POWER aix-7.3-power]

      # Fedora
      (19..38).each do |release|
        # 32 bit support was dropped in Fedora 31
        yield ["fedora#{release}-32", "fedora-#{release}-i386"] if release < 31

        yield ["fedora#{release}-64", "fedora-#{release}-x86_64"]
      end

      # Ubuntu
      #
      # Generate LTS platforms
      (18..22).select(&:even?).each do |release|
        yield ["ubuntu#{release}04-64", "ubuntu-#{release}.04-amd64"]

        yield ["ubuntu#{release}04-POWER", "ubuntu-#{release}.04-ppc64el"]

        yield ["ubuntu#{release}04-AARCH64", "ubuntu-#{release}.04-aarch64"]
      end

      # Generate STS platforms
      [20, 21].each do |release|
        # Even years are LTS releases
        yield ["ubuntu#{release}04-64", "ubuntu-#{release}.04-amd64"] unless release.even?

        yield ["ubuntu#{release}10-64", "ubuntu-#{release}.10-amd64"]
      end

      # FreeBSD
      (12..13).each do |release|
        yield ["freebsd#{release}-64", "freebsd-#{release}-amd64"]
      end

      # Amazon Linux
      yield %w[amazon2023-64 amazon-2023-x86_64]
      yield %w[amazon2023-AARCH64 amazon-2023-aarch64]

      # AlmaLinux and Rocky
      %w[almalinux rocky].each do |os|
        (8..9).each do |release|
          yield ["#{os}#{release}-64", "el-#{release}-x86_64"]
        end
      end

      # Oracle / OracleLinux
      yield ['oracle6-32', 'el-6-i386']
      (6..9).each do |release|
        yield ["oracle#{release}-64", "el-#{release}-x86_64"]
      end

      # Scientific Linux
      yield ['scientific7-64', 'el-7-x86_64']

      # OpenSUSE
      [15, 42].each do |release|
        yield ["opensuse#{release}-32", "opensuse-#{release}-i386"]
        yield ["opensuse#{release}-64", "opensuse-#{release}-x86_64"]
      end

      # macOS
      yield %w[osx14-64 osx-14-x86_64]
      yield %w[osx14-ARM64 osx-14-arm64]
    end
  end
end
