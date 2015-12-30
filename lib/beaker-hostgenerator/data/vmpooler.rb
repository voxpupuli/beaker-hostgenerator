module BeakerHostGenerator
  module Data
    module Vmpooler

      OSINFO = {
        'arista4-32' => {
          'platform' => 'eos-4-i386',
          'template' => 'arista-4-i386'
        },
        'centos4-32' => {
          'platform' => 'el-4-i386',
          'template' => 'centos-4-i386'
        },
        'centos4-64' => {
          'platform' => 'el-4-x86_64',
          'template' => 'centos-4-x86_64'
        },
        'centos5-32' => {
          'platform' => 'el-5-i386',
          'template' => 'centos-5-i386'
        },
        'centos5-64' => {
          'platform' => 'el-5-x86_64',
          'template' => 'centos-5-x86_64'
        },
        'centos6-32' => {
          'platform' => 'el-6-i386',
          'template' => 'centos-6-i386'
        },
        'centos6-64' => {
          'platform' => 'el-6-x86_64',
          'template' => 'centos-6-x86_64'
        },
        'centos7-64' => {
          'platform' => 'el-7-x86_64',
          'template' => 'centos-7-x86_64'
        },
        'cisconxos5-64' => {
          'platform' => 'cisco-5-x86_64',
          'template' => 'cisco-nxos-9k-x86_64'
        },
        'ciscoexr7-64' => {
          'platform' => 'cisco-7-x86_64',
          'template' => 'cisco-exr-9k-x86_64'
        },
        'cumulus25-64' => {
          'platform' => 'cumulus-2.5-x86_64',
          'template' => 'cumulus-vx-25-x86_64'
        },
        'debian6-32' => {
          'platform' => 'debian-6-i386',
          'template' => 'debian-6-i386'
        },
        'debian6-64' => {
          'platform' => 'debian-6-amd64',
          'template' => 'debian-6-x86_64'
        },
        'debian7-32' => {
          'platform' => 'debian-7-i386',
          'template' => 'debian-7-i386'
        },
        'debian7-64' => {
          'platform' => 'debian-7-amd64',
          'template' => 'debian-7-x86_64'
        },
        'debian8-32' => {
          'platform' => 'debian-8-i386',
          'template' => 'debian-8-i386'
        },
        'debian8-64' => {
          'platform' => 'debian-8-amd64',
          'template' => 'debian-8-x86_64'
        },
        'debian9-32' => {
          'platform' => 'debian-9-i386',
          'template' => 'debian-9-i386'
        },
        'debian9-64' => {
          'platform' => 'debian-9-amd64',
          'template' => 'debian-9-x86_64'
        },
        'oracle5-32' => {
          'platform' => 'el-5-i386',
          'template' => 'oracle-5-i386'
        },
        'oracle5-64' => {
          'platform' => 'el-5-x86_64',
          'template' => 'oracle-5-x86_64'
        },
        'oracle6-32' => {
          'platform' => 'el-6-i386',
          'template' => 'oracle-6-i386'
        },
        'oracle6-64' => {
          'platform' => 'el-6-x86_64',
          'template' => 'oracle-6-x86_64'
        },
        'oracle7-64' => {
          'platform' => 'el-7-x86_64',
          'template' => 'oracle-7-x86_64'
        },
        'osx109-64' => {
          'platform' => 'osx-10.9-x86_64',
          'template' => 'osx-109-x86_64'
        },
        'osx1010-64' => {
          'platform' => 'osx-10.10-x86_64',
          'template' => 'osx-1010-x86_64'
        },
        'osx1011-64' => {
          'platform' => 'osx-10.11-x86_64',
          'template' => 'osx-1011-x86_64'
        },
        'redhat4-32' => {
          'platform' => 'el-4-i386',
          'template' => 'redhat-4-i386'
        },
        'redhat4-64' => {
          'platform' => 'el-4-x86_64',
          'template' => 'redhat-4-x86_64'
        },
        'redhat5-32' => {
          'platform' => 'el-5-i386',
          'template' => 'redhat-5-i386'
        },
        'redhat5-64' => {
          'platform' => 'el-5-x86_64',
          'template' => 'redhat-5-x86_64'
        },
        'redhat6-32' => {
          'platform' => 'el-6-i386',
          'template' => 'redhat-6-i386'
        },
        'redhat6-64' => {
          'platform' => 'el-6-x86_64',
          'template' => 'redhat-6-x86_64'
        },
        'redhat7-64' => {
          'platform' => 'el-7-x86_64',
          'template' => 'redhat-7-x86_64'
        },
        'fedora14-32' => {
          'platform' => 'fedora-14-i386',
          'template' => 'fedora-14-i386'
        },
        'fedora19-32' => {
          'platform' => 'fedora-19-i386',
          'template' => 'fedora-19-i386'
        },
        'fedora19-64' => {
          'platform' => 'fedora-19-x86_64',
          'template' => 'fedora-19-x86_64'
        },
        'fedora20-32' => {
          'platform' => 'fedora-20-i386',
          'template' => 'fedora-20-i386'
        },
        'fedora20-64' => {
          'platform' => 'fedora-20-x86_64',
          'template' => 'fedora-20-x86_64'
        },
        'fedora21-32' => {
          'platform' => 'fedora-21-i386',
          'template' => 'fedora-21-i386'
        },
        'fedora21-64' => {
          'platform' => 'fedora-21-x86_64',
          'template' => 'fedora-21-x86_64'
        },
        'fedora22-32' => {
          'platform' => 'fedora-22-i386',
          'template' => 'fedora-22-i386'
        },
        'fedora22-64' => {
          'platform' => 'fedora-22-x86_64',
          'template' => 'fedora-22-x86_64'
        },
        'fedora23-32' => {
          'platform' => 'fedora-23-i386',
          'template' => 'fedora-23-i386'
        },
        'fedora23-64' => {
          'platform' => 'fedora-23-x86_64',
          'template' => 'fedora-23-x86_64'
        },
        'opensuse11-32' => {
          'platform' => 'opensuse-11-i386',
          'template' => 'opensuse-11-i386'
        },
        'opensuse11-64' => {
          'platform' => 'opensuse-11-x86_64',
          'template' => 'opensuse-11-x86_64'
        },
        'scientific5-32' => {
          'platform' => 'el-5-i386',
          'template' => 'scientific-5-i386'
        },
        'scientific5-64' => {
          'platform' => 'el-5-x86_64',
          'template' => 'scientific-5-x86_64'
        },
        'scientific6-32' => {
          'platform' => 'el-6-i386',
          'template' => 'scientific-6-i386'
        },
        'scientific6-64' => {
          'platform' => 'el-6-x86_64',
          'template' => 'scientific-6-x86_64'
        },
        'scientific7-64' => {
          'platform' => 'el-7-x86_64',
          'template' => 'scientific-7-x86_64'
        },
        'sles10-32' => {
          'platform' => 'sles-10-i386',
          'template' => 'sles-10-i386'
        },
        'sles10-64' => {
          'platform' => 'sles-10-x86_64',
          'template' => 'sles-10-x86_64'
        },
        'sles11-32' => {
          'platform' => 'sles-11-i386',
          'template' => 'sles-11-i386'
        },
        'sles11-64' => {
          'platform' => 'sles-11-x86_64',
          'template' => 'sles-11-x86_64'
        },
        'sles12-64' => {
          'platform' => 'sles-12-x86_64',
          'template' => 'sles-12-x86_64'
        },
        'solaris10-32' => {
          'platform' => 'solaris-10-i386',
          'template' => 'solaris-10-x86_64'
        },
        'solaris10-64' => {
          'platform' => 'solaris-10-i386',
          'template' => 'solaris-10-x86_64'
        },
        'solaris11-32' => {
          'platform' => 'solaris-11-i386',
          'template' => 'solaris-11-x86_64'
        },
        'solaris11-64' => {
          'platform' => 'solaris-11-i386',
          'template' => 'solaris-11-x86_64'
        },
        'solaris112-32' => {
          'platform' => 'solaris-11.2-i386',
          'template' => 'solaris-112-x86_64'
        },
        'solaris112-64' => {
          'platform' => 'solaris-11.2-i386',
          'template' => 'solaris-112-x86_64'
        },
        'ubuntu1004-32' => {
          'platform' => 'ubuntu-10.04-i386',
          'template' => 'ubuntu-1004-i386'
        },
        'ubuntu1004-64' => {
          'platform' => 'ubuntu-10.04-amd64',
          'template' => 'ubuntu-1004-x86_64'
        },
        'ubuntu1204-32' => {
          'platform' => 'ubuntu-12.04-i386',
          'template' => 'ubuntu-1204-i386'
        },
        'ubuntu1204-64' => {
          'platform' => 'ubuntu-12.04-amd64',
          'template' => 'ubuntu-1204-x86_64'
        },
        'ubuntu1404-32' => {
          'platform' => 'ubuntu-14.04-i386',
          'template' => 'ubuntu-1404-i386'
        },
        'ubuntu1404-64' => {
          'platform' => 'ubuntu-14.04-amd64',
          'template' => 'ubuntu-1404-x86_64'
        },
        'ubuntu1504-32' => {
          'platform' => 'ubuntu-15.04-i386',
          'template' => 'ubuntu-1504-i386'
        },
        'ubuntu1504-64' => {
          'platform' => 'ubuntu-15.04-amd64',
          'template' => 'ubuntu-1504-x86_64'
        },
        'ubuntu1510-32' => {
          'platform' => 'ubuntu-15.10-i386',
          'template' => 'ubuntu-1510-i386'
        },
        'ubuntu1510-64' => {
          'platform' => 'ubuntu-15.10-amd64',
          'template' => 'ubuntu-1510-x86_64'
        },
        'windows2003-64' => {
          'platform' => 'windows-2003-64',
          'template' => 'win-2003-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows2003-6432' => {
          'platform' => 'windows-2003-64',
          'template' => 'win-2003-x86_64',
          'ruby_arch' => 'x86'
        },
        'windows2003r2-32' => {
          'platform' => 'windows-2003r2-32',
          'template' => 'win-2003r2-i386',
          'ruby_arch' => 'x86'
        },
        'windows2003r2-64' => {
          'platform' => 'windows-2003r2-64',
          'template' => 'win-2003r2-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows2003r2-6432' => {
          'platform' => 'windows-2003r2-64',
          'template' => 'win-2003r2-x86_64',
          'ruby_arch' => 'x86'
        },
        'windows2008-64' => {
          'platform' => 'windows-2008-64',
          'template' => 'win-2008-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows2008-6432' => {
          'platform' => 'windows-2008-64',
          'template' => 'win-2008-x86_64',
          'ruby_arch' => 'x86'
        },
        'windows2008r2-64' => {
          'platform' => 'windows-2008r2-64',
          'template' => 'win-2008r2-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows2008r2-6432' => {
          'platform' => 'windows-2008r2-64',
          'template' => 'win-2008r2-x86_64',
          'ruby_arch' => 'x86'
        },
        'windows2012-64' => {
          'platform' => 'windows-2012-64',
          'template' => 'win-2012-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows2012-6432' => {
          'platform' => 'windows-2012-64',
          'template' => 'win-2012-x86_64',
          'ruby_arch' => 'x86'
        },
        'windows2012r2-64' => {
          'platform' => 'windows-2012r2-64',
          'template' => 'win-2012r2-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows2012r2-6432' => {
          'platform' => 'windows-2012r2-64',
          'template' => 'win-2012r2-x86_64',
          'ruby_arch' => 'x86'
        },
        'windows7-64' => {
          'platform' => 'windows-7-64',
          'template' => 'win-7-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows8-64' => {
          'platform' => 'windows-8-64',
          'template' => 'win-8-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows81-64' => {
          'platform' => 'windows-8.1-64',
          'template' => 'win-81-x86_64',
          'ruby_arch' => 'x64'
        },
        'windowsvista-64' => {
          'platform' => 'windows-vista-64',
          'template' => 'win-vista-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows10ent-32' => {
          'platform' => 'windows-10ent-32',
          'template' => 'win-10-ent-i386',
          'ruby_arch' => 'x86'
        },
        'windows10ent-64' => {
          'platform' => 'windows-10ent-x86_64',
          'template' => 'win-10-ent-x86_64',
          'ruby_arch' => 'x64'
        },
        'windows10pro-64' => {
          'platform' => 'windows-10pro-x86_64',
          'template' => 'win-10-pro-x86_64',
          'ruby_arch' => 'x64'
        },
      }

      OSINFO_BHGv1 = {
        'centos4-32' => {
          'platform' => 'centos-4-i386',
          'template' => 'centos-4-i386'
        },
        'centos4-64' => {
          'platform' => 'centos-4-x86_64',
          'template' => 'centos-4-x86_64'
        },
        'centos5-32' => {
          'platform' => 'centos-5-i386',
          'template' => 'centos-5-i386'
        },
        'centos5-64' => {
          'platform' => 'centos-5-x86_64',
          'template' => 'centos-5-x86_64'
        },
        'centos6-32' => {
          'platform' => 'centos-6-i386',
          'template' => 'centos-6-i386'
        },
        'centos6-64' => {
          'platform' => 'centos-6-x86_64',
          'template' => 'centos-6-x86_64'
        },
        'centos7-64' => {
          'platform' => 'centos-7-x86_64',
          'template' => 'centos-7-x86_64'
        },
      }

      VMPOOLER_CONFIG = {
        'HOSTS' => {},
        'CONFIG' => {
          'pooling_api' => 'http://vmpooler.delivery.puppetlabs.net/'
        }
      }

      def get_osinfo(bhg_version=0)
        case bhg_version
        when 0
          osinfo = OSINFO
        when 1
          osinfo = OSINFO
          osinfo.deep_merge! OSINFO_BHGv1
        else
          raise "Invalid beaker-hostgenerator version: #{bhg_version}"
        end
        return osinfo
      end

      module_function :get_osinfo
    end
  end
end
