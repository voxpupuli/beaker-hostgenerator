require 'beaker-hostgenerator/cli'
require 'json'

module BeakerHostGenerator
  describe AbsSupport do
    describe 'extract_templates' do
      it 'Returns a JSON map with template counts' do
        input = ['aix53-POWER-aix61-POWER-aix71-POWER-aix72-POWER-huaweios6-POWER-redhat7-POWER-solaris10-SPARC-solaris11-SPARC-centos7-64-ubuntu1604-POWER',
                 '--templates-only',
                 '--hypervisor', 'abs']
        expect( JSON.load(BeakerHostGenerator::CLI.new(input).execute) ).
          to eq({'aix-5.3-power' => 1,
                 'aix-6.1-power' => 1,
                 'aix-7.1-power' => 1,
                 'aix-7.2-power' => 1,
                 'huaweios-6-powerpc' => 1,
                 'rhel-7.3-power8' => 1,
                 'solaris-10-sparc' => 1,
                 'solaris-11-sparc' => 1,
                 'centos-7-x86_64' => 1,
                 'ubuntu-16.04-power8' => 1})
      end
    end
  end
end
