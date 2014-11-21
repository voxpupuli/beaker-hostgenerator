module GenConfig
  module Data
    module VSphere

      OSINFO = {
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
        'osx109-64' => {
          'platform' => 'osx-10.9-x86_64',
          'template' => 'osx-109-x86_64'
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
        'solaris10-64' => {
          'platform' => 'solaris-10-i386',
          'template' => 'solaris-10-x86_64'
        },
        'solaris11-64' => {
          'platform' => 'solaris-11-i386',
          'template' => 'solaris-11-x86_64'
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
        'windows2003-64' => {
          'platform' => 'windows-2003-64',
          'template' => 'win-2003-x86_64'
        },
        'windows2003r2-32' => {
          'platform' => 'windows-2003r2-32',
          'template' => 'win-2003r2-i386'
        },
        'windows2003r2-64' => {
          'platform' => 'windows-2003r2-64',
          'template' => 'win-2003r2-x86_64',
        },
        'windows2008-64' => {
          'platform' => 'windows-2008-64',
          'template' => 'win-2008-x86_64'
        },
        'windows2008r2-64' => {
          'platform' => 'windows-2008r2-64',
          'template' => 'win-2008r2-x86_64'
        },
        'windows2012-64' => {
          'platform' => 'windows-2012-64',
          'template' => 'win-2012-x86_64'
        },
        'windows2012r2-64' => {
          'platform' => 'windows-2012r2-64',
          'template' => 'win-2012r2-x86_64'
        }
      }

      # Prepended to all Templates. This uniquely identifies them, because
      # their names are fairly generic.
      QA_VCENTER_PATH = 'Delivery/Quality Assurance/Templates/vCloud'

      VSPHERE_CONFIG = {
        'HOSTS' => {},
        'CONFIG' => {
          'datastore' => 'instance0',
          'folder' => 'Delivery/Quality Assurance/Enterprise/Dynamic',
          'resourcepool' => 'delivery/Quality Assurance/Enterprise/Dynamic',
          'pooling_api' => 'http://vcloud.delivery.puppetlabs.net/'
        }
      }

    end
  end
end
