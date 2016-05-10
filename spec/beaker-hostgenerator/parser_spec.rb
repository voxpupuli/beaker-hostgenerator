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

      context 'When using arbitrary host settings' do
        it 'Supports arbitrary whitespace' do
          expect( parse_node_info_token("64{ k1=v1, k2=v2,  k3 = v3 ,  k4  =v4  }") ).
            to eq({
                    "roles" => "",
                    "arbitrary_roles" => [],
                    "bits" => "64",
                    "host_settings" => {
                      "k1" => "v1",
                      "k2" => "v2",
                      "k3" => "v3",
                      "k4" => "v4"
                    }
                  })
        end

        it 'Raises InvalidNodeSpecError for malformed key-value pairs' do
          expect { parse_node_info_token("64{foo=bar=baz}") }.
            to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)

          expect { parse_node_info_token("64{foo=}") }.
            to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)

          expect { parse_node_info_token("64{=bar}") }.
            to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)

          expect { parse_node_info_token("64{=}") }.
            to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
        end
      end
    end
  end
end
