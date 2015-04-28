require 'genconfig'
require 'spec_helper'

module GenConfig
  describe Generator do
    let(:options) {
      {
        list_platforms_and_roles: false,
        disable_default_role: false,
        disable_role_config: false,
        hypervisor: 'vmpooler',
      }
    }
    let(:generator) { GenConfig::Generator.new(options) }

    describe '__generate_host_roles' do
      it 'Generates a list of roles' do
        {
          {
            "roles" => "aulcdfm",
            "arbitrary_roles" => [],
          } => [
            'agent',
            'ca',
            'classifier',
            'dashboard',
            'database',
            'frictionless',
            'master',
            ],
          {
            "roles" => "a",
            "arbitrary_roles" => ["meow","hello","compile_master"],
          } => [
            'agent',
            'meow',
            'hello',
            'compile_master',
            ],
          {
            "roles" => "",
            "arbitrary_roles" => ["compile_master"],
          } => [
            'compile_master'
            ],
          {
            "roles" => "",
            "arbitrary_roles" => [],
          } => [],
        }.each do |node_info, roles|
          expect( generator.__generate_host_roles(node_info) ).to eq( roles )
        end
      end
    end

    describe '__parse_node_info_token' do

      it 'Raises InvalidNodeSpecError for invalid tokens.' do
        expect{ generator.__parse_node_info_token("64compile_master") }.to \
          raise_error(GenConfig::Errors::InvalidNodeSpecError)
      end

      it 'Supports no roles in the spec.' do
        node_info = generator.__parse_node_info_token("64")
        expect( node_info ).to eq({
          "roles" => "",
          "arbitrary_roles" => [],
          "bits" => "64",
        })
      end

      it 'Supports the use of arbitrary roles.' do
        node_info = generator.__parse_node_info_token("64compile_master,ca,blah.mad")
        expect( node_info ).to eq({
          "roles" => "mad",
          "arbitrary_roles" => ["compile_master", "ca", "blah"],
          "bits" => "64",
        })
      end

      context 'When using arbitrary roles'do
        it 'Fails without a role-type delimiter (a period)' do
          expect{ generator.__parse_node_info_token("64compile_master,ca,blah") }.to \
            raise_error(GenConfig::Errors::InvalidNodeSpecError)
        end
        it 'It supports no static roles.' do
          node_info = generator.__parse_node_info_token("64compile_master,ca,blah.")
          expect( node_info ).to eq({
            "roles" => "",
            "arbitrary_roles" => ["compile_master", "ca", "blah"],
            "bits" => "64",
          })
        end
      end
    end

  end
end

