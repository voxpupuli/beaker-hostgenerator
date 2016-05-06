require 'beaker-hostgenerator/parser'

module BeakerHostGenerator
  describe Parser do
    include BeakerHostGenerator::Parser

    describe 'parse_node_info_token' do

      it 'Raises InvalidNodeSpecError for invalid tokens.' do
        expect { parse_node_info_token("64compile_master") }.
          to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
      end

      it 'Supports no roles in the spec.' do
        expect( parse_node_info_token("64") ).
          to eq({
                  "roles" => "",
                  "arbitrary_roles" => [],
                  "bits" => "64",
                  "host_settings" => {}
                })
      end

      it 'Supports the use of arbitrary roles.' do
        expect( parse_node_info_token("64compile_master,ca,blah.mad") ).
          to eq({
                  "roles" => "mad",
                  "arbitrary_roles" => ["compile_master", "ca", "blah"],
                  "bits" => "64",
                  "host_settings" => {}
                })
      end

      context 'When using arbitrary roles' do

        it 'Fails without a role-type delimiter (a period)' do
          expect { parse_node_info_token("64compile_master,ca,blah") }.
            to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
        end

        it 'It supports no static roles.' do
          expect( parse_node_info_token("64compile_master,ca,blah.") ).
            to eq({
                    "roles" => "",
                    "arbitrary_roles" => ["compile_master", "ca", "blah"],
                    "bits" => "64",
                    "host_settings" => {}
                  })
        end
      end
    end
  end
end
