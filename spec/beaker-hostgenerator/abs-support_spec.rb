require 'beaker-hostgenerator/cli'
require 'json'

module BeakerHostGenerator
  describe AbsSupport do
    describe 'extract_templates' do
      it 'Returns a JSON map with template counts' do
        input = ['--templates-only', 'centos6-64m-centos6-64m-redhat7-64m']
        expect( JSON.load(BeakerHostGenerator::CLI.new(input).execute) ).
          to eq({"centos-6-x86_64" => 2, "redhat-7-x86_64" => 1})
      end
    end
  end
end
