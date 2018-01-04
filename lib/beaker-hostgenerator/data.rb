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

    PE_TARBALL_SERVER="http://enterprise.delivery.puppetlabs.net"

    def pe_version
      ENV['pe_version']
    end

    def pe_upgrade_version
      ENV['pe_upgrade_version']
    end

    def pe_dir(version)
      return if version.nil? || version.empty?

      base_regex = '(\A\d+\.\d+)\.\d+'
      source = case version
      when /#{base_regex}\Z/
        then "#{PE_TARBALL_SERVER}/archives/releases/#{version}/"
      when /#{base_regex}-rc\d+\Z/
        then "#{PE_TARBALL_SERVER}/archives/internal/%s/"
      when /#{base_regex}-.*PEZ_.*/
        then "#{PE_TARBALL_SERVER}/%s/feature/ci-ready"
      when /#{base_regex}-.*/
        then "#{PE_TARBALL_SERVER}/%s/ci-ready"
      else
        ''
      end
      return sprintf(source, ($1 || ''))
    end

    PE_USE_WIN32 = ENV['pe_use_win32']

    BASE_CONFIG = {
      'HOSTS' => {},
      'CONFIG' => {
        'nfs_server' => 'none',
        'consoleport' => 443,
      }
    }

    def base_host_config(options)
      {
        'pe_dir' => options[:pe_dir] || pe_dir(pe_version),
        'pe_ver' => options[:pe_ver] || pe_version,
        'pe_upgrade_dir' => options[:pe_upgrade_dir] || pe_dir(pe_upgrade_version),
        'pe_upgrade_ver' => options[:pe_upgrade_ver] || pe_upgrade_version,
      }
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
      {
        'aix53-POWER' => {
          :general => {
            'platform'           => 'aix-5.3-power',
            'packaging_platform' => 'aix-5.3-power'
          },
          :abs => {
            'template' => 'aix-5.3-power'
          }
        },
        'aix61-POWER' => {
          :general => {
            'platform'           => 'aix-6.1-power',
            'packaging_platform' => 'aix-6.1-power'
          },
          :abs => {
            'template' => 'aix-6.1-power'
          }
        },
        'aix71-POWER' => {
          :general => {
            'platform'           => 'aix-7.1-power',
            'packaging_platform' => 'aix-7.1-power'
          },
          :abs => {
            'template' => 'aix-7.1-power'
          }
        },
        'aix72-POWER' => {
          :general => {
            'platform'           => 'aix-7.2-power',
            'packaging_platform' => 'aix-7.1-power'
          },
          :abs => {
            'template' => 'aix-7.2-power'
          }
        },
        'amazon6-64' => {
            :general => {
                'platform'           => 'el-6-x86_64',
                'packaging_platform' => 'el-6-x86_64'
            },
            :abs => {
                'template' => 'amazon-6-x86_64'
            }
        },
        'amazon7-64' => {
            :general => {
                'platform'           => 'el-7-x86_64',
                'packaging_platform' => 'el-7-x86_64'
            },
            :abs => {
                'template' => 'amazon-7-x86_64'
            }
        },
        'arista4-32' => {
          :general => {
            'platform'           => 'eos-4-i386',
            'packaging_platform' => 'eos-4-i386'
          },
          :vmpooler => {
            'template' => 'arista-4-i386'
          }
        },
        'centos4-32' => {
          :general => {
            'platform' => 'el-4-i386'
          },
          :vmpooler => {
            'template' => 'centos-4-i386'
          }
        },
        'centos4-64' => {
          :general => {
            'platform' => 'el-4-x86_64'
          },
          :vmpooler => {
            'template' => 'centos-4-x86_64'
          }
        },
        'centos5-32' => {
          :general => {
            'platform'           => 'el-5-i386',
            'packaging_platform' => 'el-5-i386'
          },
          :vmpooler => {
            'template' => 'centos-5-i386'
          }
        },
        'centos5-64' => {
          :general => {
            'platform'           => 'el-5-x86_64',
            'packaging_platform' => 'el-5-x86_64'
          },
          :vmpooler => {
            'template' => 'centos-5-x86_64'
          }
        },
        'centos6-32' => {
          :general => {
            'platform'           => 'el-6-i386',
            'packaging_platform' => 'el-6-i386'
          },
          :vmpooler => {
            'template' => 'centos-6-i386'
          }
        },
        'centos6-64' => {
          :general => {
            'platform'           => 'el-6-x86_64',
            'packaging_platform' => 'el-6-x86_64'
          },
          :vmpooler => {
            'template' => 'centos-6-x86_64'
          }
        },
        'centos7-64' => {
          :general => {
            'platform'           => 'el-7-x86_64',
            'packaging_platform' => 'el-7-x86_64'
          },
          :vmpooler => {
            'template' => 'centos-7-x86_64'
          }
        },
        'cisconx-64' => {
          :general => {
            'platform'           => 'cisco_nexus-7-x86_64',
            'packaging_platform' => 'cisco-wrlinux-5-x86_64',
            'vrf' => 'management',
            'ssh' => {
              'user' => 'beaker'
            }
          },
          :vmpooler => {
            'template' => 'cisco-nxos-9k-x86_64'
          }
        },
        'cisconxhw-64' => {
          :general => {
            'platform'           => 'cisco_nexus-7-x86_64',
            'packaging_platform' => 'cisco-wrlinux-5-x86_64',
            'vrf' => 'management',
            'ssh' => {
              'user' => 'devops'
            }
          },
          :abs => {
            'template' => 'cisco-nxos_hw-9k-x86_64'
          }
        },
        'ciscoxr-64' => {
          :general => {
            'platform'           => 'cisco_ios_xr-6-x86_64',
            'packaging_platform' => 'cisco-wrlinux-7-x86_64'
          },
          :vmpooler => {
            'template' => 'cisco-exr-9k-x86_64'
          }
        },
        'cumulus25-64' => {
          :general => {
            'platform'           => 'cumulus-2.5-x86_64',
            'packaging_platform' => 'cumulus-2.2-amd64'
          },
          :vmpooler => {
            'template' => 'cumulus-vx-25-x86_64'
          }
        },
        'debian6-32' => {
          :general => {
            'platform' => 'debian-6-i386'
          },
          :vmpooler => {
            'template' => 'debian-6-i386'
          }
        },
        'debian6-64' => {
          :general => {
            'platform' => 'debian-6-amd64'
          },
          :vmpooler => {
            'template' => 'debian-6-x86_64'
          }
        },
        'debian7-32' => {
          :general => {
            'platform'           => 'debian-7-i386',
            'packaging_platform' => 'debian-7-i386'
          },
          :vmpooler => {
            'template' => 'debian-7-i386'
          }
        },
        'debian7-64' => {
          :general => {
            'platform'           => 'debian-7-amd64',
            'packaging_platform' => 'debian-7-amd64'
          },
          :vmpooler => {
            'template' => 'debian-7-x86_64'
          }
        },
        'debian8-32' => {
          :general => {
            'platform'           => 'debian-8-i386',
            'packaging_platform' => 'debian-8-i386'
          },
          :vmpooler => {
            'template' => 'debian-8-i386'
          }
        },
        'debian8-64' => {
          :general => {
            'platform'           => 'debian-8-amd64',
            'packaging_platform' => 'debian-8-amd64'
          },
          :vmpooler => {
            'template' => 'debian-8-x86_64'
          }
        },
        'debian9-32' => {
          :general => {
            'platform'           => 'debian-9-i386',
            'packaging_platform' => 'debian-9-i386'
          },
          :vmpooler => {
            'template' => 'debian-9-i386'
          }
        },
        'debian9-64' => {
          :general => {
            'platform'           => 'debian-9-amd64',
            'packaging_platform' => 'debian-9-amd64'
          },
          :vmpooler => {
            'template' => 'debian-9-x86_64'
          }
        },
        'fedora14-32' => {
          :general => {
            'platform' => 'fedora-14-i386'
          },
          :vmpooler => {
            'template' => 'fedora-14-i386'
          }
        },
        'fedora19-32' => {
          :general => {
            'platform' => 'fedora-19-i386'
          },
          :vmpooler => {
            'template' => 'fedora-19-i386'
          }
        },
        'fedora19-64' => {
          :general => {
            'platform' => 'fedora-19-x86_64'
          },
          :vmpooler => {
            'template' => 'fedora-19-x86_64'
          }
        },
        'fedora20-32' => {
          :general => {
            'platform' => 'fedora-20-i386'
          },
          :vmpooler => {
            'template' => 'fedora-20-i386'
          }
        },
        'fedora20-64' => {
          :general => {
            'platform' => 'fedora-20-x86_64'
          },
          :vmpooler => {
            'template' => 'fedora-20-x86_64'
          }
        },
        'fedora21-32' => {
          :general => {
            'platform' => 'fedora-21-i386'
          },
          :vmpooler => {
            'template' => 'fedora-21-i386'
          }
        },
        'fedora21-64' => {
          :general => {
            'platform' => 'fedora-21-x86_64'
          },
          :vmpooler => {
            'template' => 'fedora-21-x86_64'
          }
        },
        'fedora22-32' => {
          :general => {
            'platform' => 'fedora-22-i386'
          },
          :vmpooler => {
            'template' => 'fedora-22-i386'
          }
        },
        'fedora22-64' => {
          :general => {
            'platform' => 'fedora-22-x86_64'
          },
          :vmpooler => {
            'template' => 'fedora-22-x86_64'
          }
        },
        'fedora23-32' => {
          :general => {
            'platform' => 'fedora-23-i386'
          },
          :vmpooler => {
            'template' => 'fedora-23-i386'
          }
        },
        'fedora23-64' => {
          :general => {
            'platform' => 'fedora-23-x86_64'
          },
          :vmpooler => {
            'template' => 'fedora-23-x86_64'
          }
        },
        'fedora24-32' => {
          :general => {
            'platform'           => 'fedora-24-i386',
            'packaging_platform' => 'fedora-24-i386'
          },
          :vmpooler => {
            'template' => 'fedora-24-i386'
          }
        },
        'fedora24-64' => {
          :general => {
            'platform'           => 'fedora-24-x86_64',
            'packaging_platform' => 'fedora-24-x86_64'
          },
          :vmpooler => {
            'template' => 'fedora-24-x86_64'
          }
        },
        'fedora25-32' => {
          :general => {
            'platform'           => 'fedora-25-i386',
            'packaging_platform' => 'fedora-25-i386'
          },
          :vmpooler => {
            'template' => 'fedora-25-i386'
          }
        },
        'fedora25-64' => {
          :general => {
            'platform'           => 'fedora-25-x86_64',
            'packaging_platform' => 'fedora-25-x86_64'
          },
          :vmpooler => {
            'template' => 'fedora-25-x86_64'
          }
        },
        'fedora26-64' => {
          :general => {
            'platform'           => 'fedora-26-x86_64',
            'packaging_platform' => 'fedora-26-x86_64'
          },
          :vmpooler => {
            'template' => 'fedora-26-x86_64'
          }
        },
        'huaweios6-POWER' => {
          :general => {
            'platform' => 'huaweios-6-powerpc'
          },
          :abs => {
            'template' => 'huaweios-6-powerpc'
          }
        },
        'opensuse11-32' => {
          :general => {
            'platform' => 'opensuse-11-i386'
          },
          :vmpooler => {
            'template' => 'opensuse-11-i386'
          }
        },
        'opensuse11-64' => {
          :general => {
            'platform' => 'opensuse-11-x86_64'
          },
          :vmpooler => {
            'template' => 'opensuse-11-x86_64'
          }
        },
        'oracle5-32' => {
          :general => {
            'platform'           => 'el-5-i386',
            'packaging_platform' => 'el-5-i386'
          },
          :vmpooler => {
            'template' => 'oracle-5-i386'
          }
        },
        'oracle5-64' => {
          :general => {
            'platform'           => 'el-5-x86_64',
            'packaging_platform' => 'el-5-x86_64'
          },
          :vmpooler => {
            'template' => 'oracle-5-x86_64'
          }
        },
        'oracle6-32' => {
          :general => {
            'platform'           => 'el-6-i386',
            'packaging_platform' => 'el-6-i386'
          },
          :vmpooler => {
            'template' => 'oracle-6-i386'
          }
        },
        'oracle6-64' => {
          :general => {
            'platform'           => 'el-6-x86_64',
            'packaging_platform' => 'el-6-x86_64'
          },
          :vmpooler => {
            'template' => 'oracle-6-x86_64'
          }
        },
        'oracle7-64' => {
          :general => {
            'platform'           => 'el-7-x86_64',
            'packaging_platform' => 'el-7-x86_64'
          },
          :vmpooler => {
            'template' => 'oracle-7-x86_64'
          }
        },
        'osx109-64' => {
          :general => {
            'platform' => 'osx-10.9-x86_64'
          },
          :vmpooler => {
            'template' => 'osx-109-x86_64'
          }
        },
        'osx1010-64' => {
          :general => {
            'platform'           => 'osx-10.10-x86_64',
            'packaging_platform' => 'osx-10.10-x86_64'
          },
          :vmpooler => {
            'template' => 'osx-1010-x86_64'
          }
        },
        'osx1011-64' => {
          :general => {
            'platform'           => 'osx-10.11-x86_64',
            'packaging_platform' => 'osx-10.11-x86_64'
          },
          :vmpooler => {
            'template' => 'osx-1011-x86_64'
          }
        },
        'osx1012-64' => {
          :general => {
            'platform'           => 'osx-10.12-x86_64',
            'packaging_platform' => 'osx-10.12-x86_64'
          },
          :vmpooler => {
            'template' => 'osx-1012-x86_64'
          }
        },
        'osx1013-64' => {
          :general => {
            'platform'           => 'osx-10.13-x86_64',
            'packaging_platform' => 'osx-10.13-x86_64'
          },
          :vmpooler => {
            'template' => 'osx-1013-x86_64'
          }
        },
        'redhat4-32' => {
          :general => {
            'platform' => 'el-4-i386'
          },
          :vmpooler => {
            'template' => 'redhat-4-i386'
          }
        },
        'redhat4-64' => {
          :general => {
            'platform' => 'el-4-x86_64'
          },
          :vmpooler => {
            'template' => 'redhat-4-x86_64'
          }
        },
        'redhat5-32' => {
          :general => {
            'platform'          => 'el-5-i386',
            'packaging_platform' => 'el-5-i386'
          },
          :vmpooler => {
            'template' => 'redhat-5-i386'
          }
        },
        'redhat5-64' => {
          :general => {
            'platform'          => 'el-5-x86_64',
            'packaging_platform' => 'el-5-x86_64'
          },
          :vmpooler => {
            'template' => 'redhat-5-x86_64'
          }
        },
        'redhat6-32' => {
          :general => {
            'platform'          => 'el-6-i386',
            'packaging_platform' => 'el-6-i386'
          },
          :vmpooler => {
            'template' => 'redhat-6-i386'
          }
        },
        'redhat6-64' => {
          :general => {
            'platform'           => 'el-6-x86_64',
            'packaging_platform' => 'el-6-x86_64'
          },
          :vmpooler => {
            'template' => 'redhat-6-x86_64'
          }
        },
        'redhat6-S390X' => {
          :general => {
            'platform'          => 'el-6-s390x',
            'packaging_platform' => 'el-6-s390x'
          },
        },
        'redhat7-64' => {
          :general => {
            'platform'           => 'el-7-x86_64',
            'packaging_platform' => 'el-7-x86_64'
          },
          :vmpooler => {
            'template' => 'redhat-7-x86_64'
          }
        },
        'redhat7-POWER' => {
          :general => {
            'platform'           => 'el-7-ppc64le',
            'packaging_platform' => 'el-7-ppc64le'
          },
          :abs => {
            'template' => 'redhat-7.3-power8'
          }
        },
        'redhat7-S390X' => {
          :general => {
            'platform'           => 'el-7-s390x',
            'packaging_platform' => 'el-7-s390x'
          },
        },
        'redhat7-AARCH64' => {
          :general => {
            'platform'           => 'el-7-aarch64',
            'packaging_platform' => 'el-7-aarch64'
          },
          :abs => {
            'template' => 'centos-7-arm64'
          },
          :vmpooler => {
            'template' => 'redhat-7-x86_64'
          }
        },
        'scientific5-32' => {
          :general => {
            'platform'           => 'el-5-i386',
            'packaging_platform' => 'el-5-i386'
          },
          :vmpooler => {
            'template' => 'scientific-5-i386'
          }
        },
        'scientific5-64' => {
          :general => {
            'platform'           => 'el-5-x86_64',
            'packaging_platform' => 'el-5-x86_64'
          },
          :vmpooler => {
            'template' => 'scientific-5-x86_64'
          }
        },
        'scientific6-32' => {
          :general => {
            'platform'          => 'el-6-i386',
            'packaging_platform' => 'el-6-i386'
          },
          :vmpooler => {
            'template' => 'scientific-6-i386'
          }
        },
        'scientific6-64' => {
          :general => {
            'platform'           => 'el-6-x86_64',
            'packaging_platform' => 'el-6-x86_64'
          },
          :vmpooler => {
            'template' => 'scientific-6-x86_64'
          }
        },
        'scientific7-64' => {
          :general => {
            'platform'          => 'el-7-x86_64',
            'packaging_platform' => 'el-7-x86_64'
          },
          :vmpooler => {
            'template' => 'scientific-7-x86_64'
          }
        },
        'sles10-32' => {
          :general => {
            'platform' => 'sles-10-i386'
          },
          :vmpooler => {
            'template' => 'sles-10-i386'
          }
        },
        'sles10-64' => {
          :general => {
            'platform' => 'sles-10-x86_64'
          },
          :vmpooler => {
            'template' => 'sles-10-x86_64'
          }
        },
        'sles11-32' => {
          :general => {
            'platform'           => 'sles-11-i386',
            'packaging_platform' => 'sles-11-i386'
          },
          :vmpooler => {
            'template' => 'sles-11-i386'
          }
        },
        'sles11-64' => {
          :general => {
            'platform'           => 'sles-11-x86_64',
            'packaging_platform' => 'sles-11-x86_64'
          },
          :vmpooler => {
            'template' => 'sles-11-x86_64'
          }
        },
        'sles11-S390X' => {
          :general => {
            'platform'           => 'sles-11-s390x',
            'packaging_platform' => 'sles-11-s390x'
          },
        },
        'sles12-64' => {
          :general => {
            'platform'           => 'sles-12-x86_64',
            'packaging_platform' => 'sles-12-x86_64'
          },
          :vmpooler => {
            'template' => 'sles-12-x86_64'
          }
        },
        'sles12-S390X' => {
          :general => {
            'platform'           => 'sles-12-s390x',
            'packaging_platform' => 'sles-12-s390x'
          }
        },
        'sles12-POWER' => {
          :general => {
            'platform'           => 'sles-12-ppc64le',
            'packaging_platform' => 'sles-12-ppc64le'
          },
          :abs => {
            'template' => 'sles-12-power8'
          }
        },
        'solaris10-32' => {
          :general => {
            'platform'           => 'solaris-10-i386',
            'packaging_platform' => 'solaris-10-i386'
          },
          :vmpooler => {
            'template' => 'solaris-10-x86_64'
          }
        },
        'solaris10-64' => {
          :general => {
            'platform'           => 'solaris-10-i386',
            'packaging_platform' => 'solaris-10-i386'
          },
          :vmpooler => {
            'template' => 'solaris-10-x86_64'
          }
        },
        'solaris10-SPARC' => {
          :general => {
            'platform'           => 'solaris-10-sparc',
            'packaging_platform' => 'solaris-10-sparc'
          },
          :abs => {
            'template' => 'solaris-10-sparc'
          }
        },
        'solaris11-32' => {
          :general => {
            'platform'           => 'solaris-11-i386',
            'packaging_platform' => 'solaris-11-i386'
          },
          :vmpooler => {
            'template' => 'solaris-11-x86_64'
          }
        },
        'solaris11-64' => {
          :general => {
            'platform'           => 'solaris-11-i386',
            'packaging_platform' => 'solaris-11-i386'
          },
          :vmpooler => {
            'template' => 'solaris-11-x86_64'
          }
        },
        'solaris11-SPARC' => {
          :general => {
            'platform'           => 'solaris-11-sparc',
            'packaging_platform' => 'solaris-11-sparc'
          },
          :abs => {
            'template' => 'solaris-11-sparc'
          }
        },
        'solaris112-32' => {
          :general => {
            'platform'           => 'solaris-11.2-i386',
            'packaging_platform' => 'solaris-11-i386'
          },
          :vmpooler => {
            'template' => 'solaris-112-x86_64'
          }
        },
        'solaris112-64' => {
          :general => {
            'platform'           => 'solaris-11.2-i386',
            'packaging_platform' => 'solaris-11-i386'
          },
          :vmpooler => {
            'template' => 'solaris-112-x86_64'
          }
        },
        'ubuntu1004-32' => {
          :general => {
            'platform' => 'ubuntu-10.04-i386'
          },
          :vmpooler => {
            'template' => 'ubuntu-1004-i386'
          }
        },
        'ubuntu1004-64' => {
          :general => {
            'platform' => 'ubuntu-10.04-amd64'
          },
          :vmpooler => {
            'template' => 'ubuntu-1004-x86_64'
          }
        },
        'ubuntu1204-32' => {
          :general => {
            'platform' => 'ubuntu-12.04-i386'
          },
          :vmpooler => {
            'template' => 'ubuntu-1204-i386'
          }
        },
        'ubuntu1204-64' => {
          :general => {
            'platform' => 'ubuntu-12.04-amd64'
          },
          :vmpooler => {
            'template' => 'ubuntu-1204-x86_64'
          }
        },
        'ubuntu1404-32' => {
          :general => {
            'platform'           => 'ubuntu-14.04-i386',
            'packaging_platform' => 'ubuntu-14.04-i386'
          },
          :vmpooler => {
            'template' => 'ubuntu-1404-i386'
          }
        },
        'ubuntu1404-64' => {
          :general => {
            'platform'           => 'ubuntu-14.04-amd64',
            'packaging_platform' => 'ubuntu-14.04-amd64'
          },
          :vmpooler => {
            'template' => 'ubuntu-1404-x86_64'
          }
        },
        'ubuntu1504-32' => {
          :general => {
            'platform' => 'ubuntu-15.04-i386'
          },
          :vmpooler => {
            'template' => 'ubuntu-1504-i386'
          }
        },
        'ubuntu1504-64' => {
          :general => {
            'platform' => 'ubuntu-15.04-amd64'
          },
          :vmpooler => {
            'template' => 'ubuntu-1504-x86_64'
          }
        },
        'ubuntu1510-32' => {
          :general => {
            'platform' => 'ubuntu-15.10-i386'
          },
          :vmpooler => {
            'template' => 'ubuntu-1510-i386'
          }
        },
        'ubuntu1510-64' => {
          :general => {
            'platform' => 'ubuntu-15.10-amd64'
          },
          :vmpooler => {
            'template' => 'ubuntu-1510-x86_64'
          }
        },
        'ubuntu1604-32' => {
          :general => {
            'platform'           => 'ubuntu-16.04-i386',
            'packaging_platform' => 'ubuntu-16.04-i386'
          },
          :vmpooler => {
            'template' => 'ubuntu-1604-i386'
          }
        },
        'ubuntu1604-64' => {
          :general => {
            'platform'           => 'ubuntu-16.04-amd64',
            'packaging_platform' => 'ubuntu-16.04-amd64'
          },
          :vmpooler => {
            'template' => 'ubuntu-1604-x86_64'
          }
        },
        'ubuntu1604-POWER' => {
          :general => {
            'platform'           => 'ubuntu-16.04-ppc64el',
            'packaging_platform' => 'ubuntu-16.04-ppc64el'
          },
          :abs => {
            'template' => 'ubuntu-16.04-power8'
          }
        },
        'ubuntu1610-32' => {
          :general => {
            'platform' => 'ubuntu-16.10-i386'
          },
          :vmpooler => {
            'template' => 'ubuntu-1610-i386'
          }
        },
        'ubuntu1610-64' => {
          :general => {
            'platform' => 'ubuntu-16.10-amd64'
          },
          :vmpooler => {
            'template' => 'ubuntu-1610-x86_64'
          }
        },
        'vro6-64' => {
          :general => {
            'platform'           => 'sles-11-x86_64',
            'packaging_platform' => 'sles-11-x86_64'
          },
          :vmpooler => {
            'template' => 'vro-6-x86_64'
          }
        },
        'vro7-64' => {
          :general => {
            'platform'           => 'sles-11-x86_64',
            'packaging_platform' => 'sles-11-x86_64'
          },
          :vmpooler => {
            'template' => 'vro-7-x86_64'
          }
        },
        'windows2003-64' => {
          :general => {
            'platform'           => 'windows-2003-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2003-x86_64'
          }
        },
        'windows2003-6432' => {
          :general => {
            'platform'           => 'windows-2003-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2003-x86_64'
          }
        },
        'windows2003r2-32' => {
          :general => {
            'platform'           => 'windows-2003r2-32',
            'packaging_platform' => 'windows-2012-x86',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2003r2-i386'
          }
        },
        'windows2003r2-64' => {
          :general => {
            'platform'           => 'windows-2003r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2003r2-x86_64'
          }
        },
        'windows2003r2-6432' => {
          :general => {
            'platform'           => 'windows-2003r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2003r2-x86_64'
          }
        },
        'windows2008-64' => {
          :general => {
            'platform'           => 'windows-2008-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2008-x86_64'
          }
        },
        'windows2008-6432' => {
          :general => {
            'platform'           => 'windows-2008-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2008-x86_64'
          }
        },
        'windows2008r2-64' => {
          :general => {
            'platform'           => 'windows-2008r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2008r2-x86_64'
          }
        },
        'windows2008r2-6432' => {
          :general => {
            'platform'           => 'windows-2008r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2008r2-x86_64'
          }
        },
        'windows2012-64' => {
          :general => {
            'platform'           => 'windows-2012-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2012-x86_64'
          }
        },
        'windows2012-6432' => {
          :general => {
            'platform'           => 'windows-2012-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2012-x86_64'
          }
        },
        'windows2012r2-64' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2012r2-x86_64'
          }
        },
        'windows2012r2-6432' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2012r2-x86_64'
          }
        },
        'windows2012r2_wmf5-64' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2012r2-wmf5-x86_64'
          }
        },
        'windows2012r2_ja-64' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2012r2-ja-x86_64'
          }
        },
        'windows2012r2_ja-6432' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2012r2-ja-x86_64'
          }
        },
        'windows2012r2_fr-64' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2012r2-fr-x86_64',
            'user'     => 'Administrateur'
          }
        },
        'windows2012r2_fr-6432' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2012r2-fr-x86_64',
            'user'     => 'Administrateur'
          }
        },
        'windows2012r2_core-64' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2012r2-core-x86_64'
          }
        },
        'windows2012r2_core-6432' => {
          :general => {
            'platform'           => 'windows-2012r2-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2012r2-core-x86_64'
          }
        },
        'windows2016-64' => {
          :general => {
            'platform'           => 'windows-2016-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2016-x86_64'
          }
        },
        'windows2016-6432' => {
          :general => {
            'platform'           => 'windows-2016-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2016-x86_64'
          }
        },
        'windows2016_core-64' => {
          :general => {
            'platform'           => 'windows-2016-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-2016-core-x86_64'
          }
        },
        'windows2016_core-6432' => {
          :general => {
            'platform'           => 'windows-2016-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-2016-core-x86_64'
          }
        },
        'windows7-64' => {
          :general => {
            'platform'           => 'windows-7-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-7-x86_64'
          }
        },
        'windows8-64' => {
          :general => {
            'platform'           => 'windows-8-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-8-x86_64'
          }
        },
        'windows81-64' => {
          :general => {
            'platform'           => 'windows-8.1-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-81-x86_64'
          }
        },
        'windowsvista-64' => {
          :general => {
            'platform'           => 'windows-vista-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-vista-x86_64'
          }
        },
        'windows10ent-32' => {
          :general => {
            'platform'           => 'windows-10ent-32',
            'packaging_platform' => 'windows-2012-x86',
            'ruby_arch' => 'x86'
          },
          :vmpooler => {
            'template' => 'win-10-ent-i386'
          }
        },
        'windows10ent-64' => {
          :general => {
            'platform'           => 'windows-10ent-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-10-ent-x86_64'
          }
        },
        'windows10pro-64' => {
          :general => {
            'platform'           => 'windows-10pro-64',
            'packaging_platform' => 'windows-2012-x64',
            'ruby_arch' => 'x64'
          },
          :vmpooler => {
            'template' => 'win-10-pro-x86_64'
          },
        }
      }
    end

    def osinfo_bhgv1
      {
        'centos4-32' => {
          :general => {
            'platform' => 'centos-4-i386'
          },
          :vmpooler => {
            'template' => 'centos-4-i386'
          }
        },
        'centos4-64' => {
          :general => {
            'platform' => 'centos-4-x86_64'
          },
          :vmpooler => {
            'template' => 'centos-4-x86_64'
          }
        },
        'centos5-32' => {
          :general => {
            'platform' => 'centos-5-i386'
          },
          :vmpooler => {
            'template' => 'centos-5-i386'
          }
        },
        'centos5-64' => {
          :general => {
            'platform' => 'centos-5-x86_64'
          },
          :vmpooler => {
            'template' => 'centos-5-x86_64'
          }
        },
        'centos6-32' => {
          :general => {
            'platform' => 'centos-6-i386'
          },
          :vmpooler => {
            'template' => 'centos-6-i386'
          }
        },
        'centos6-64' => {
          :general => {
            'platform' => 'centos-6-x86_64'
          },
          :vmpooler => {
            'template' => 'centos-6-x86_64'
          }
        },
        'centos7-64' => {
          :general => {
            'platform' => 'centos-7-x86_64'
          },
          :vmpooler => {
            'template' => 'centos-7-x86_64'
          }
        }
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
        {}.deep_merge!(osinfo)
      when 1
        {}.deep_merge!(osinfo).deep_merge!(osinfo_bhgv1)
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
    #         'centos6-64' => {
    #           :general => { 'platform' => 'el-6-x86_64' },
    #           :vmpooler => { 'template' => 'centos-6-x86_64' }
    #         }
    #         ...
    #
    #     Then get_platform_info(0, 'centos6-64', :vmpooler) returns:
    #         {
    #           'platform' => 'el-6-x86_64',
    #           'template' => 'centos-6-x86_64'
    #         }
    def get_platform_info(bhg_version, platform, hypervisor)
      info = get_osinfo(bhg_version)[platform]
      {}.deep_merge!(info[:general]).deep_merge!(info[hypervisor])
    end

    # Perform any adjustments or modifications necessary to the given node
    # configuration map, taking things like platform and PE version into
    # account.
    #
    # This is intended to capture any oddities that are necessary for a node
    # to be used in a particular context.
    def fixup_node(cfg)
      # PE 2.8 doesn't exist for EL 4. We use 2.0 instead.
      if cfg['platform'] =~ /el-4/ and pe_version =~ /2\.8/
        cfg['pe_ver'] = "2.0.3"
      end
    end

  end
end
