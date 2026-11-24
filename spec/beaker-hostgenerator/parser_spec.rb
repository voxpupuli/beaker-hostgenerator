require 'beaker-hostgenerator/parser'

module BeakerHostGenerator
  describe Parser do
    include BeakerHostGenerator::Parser

    describe 'prepare' do
      it 'Supports URL-encoded input' do
        expect(prepare('centos9-64m%7Bfoo=bar-baz,this=that,foo=%5Bbar,baz%5D,this=%5Bthat%5D%7D-32a'))
          .to eq('centos9-64m{foo=bar-baz,this=that,foo=[bar,baz],this=[that]}-32a')
      end
    end

    describe 'parse_layout' do
      it 'assigns each host the most recent OS type and preserves layout order' do
        nodes = parse_layout('centos9-64m-64a-debian11-64-centos9-64m--', 0)

        expect(nodes.map { |node| node.values_at('ostype', 'bits', 'roles') }).to eq(
          [%w[centos9 64 m], %w[centos9 64 a], ['debian11', '64', ''], %w[centos9 64 m]],
        )
      end

      it 'decodes nested settings and preserves literal dashes and pipes' do
        nodes = parse_layout('centos9-64m%7Bbefore=a-b,nested={value=c-d|e},after=f-g%7D-64a', 0)

        expect(nodes.first['host_settings']).to eq('before' => 'a-b', 'nested' => { 'value' => 'c-d|e' }, 'after' => 'f-g')
      end

      it 'rejects an unclosed settings block that would absorb the next host' do
        expect { parse_layout('centos9-64m{a={b=c}-64a{d=e}', 0) }
          .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError, "Unclosed '{' in host layout")
      end

      it 'rejects a closing brace after the settings block has ended' do
        expect { parse_layout('centos9-64m{key=value}}', 0) }
          .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError, "Unmatched '}' in host layout")
      end

      it 'rejects a switch away from an OS type with no hosts' do
        expect { parse_layout('centos9-debian11-64a', 0) }
          .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError, 'Error: no nodes generated for centos9')
      end

      it 'accepts a repeated OS type that already has a host' do
        nodes = parse_layout('centos9-64m-centos9-debian11-64a', 0)

        expect(nodes.map { |node| node['ostype'] }).to eq(%w[centos9 debian11])
      end

      it 'ignores a trailing OS type without hosts' do
        nodes = parse_layout('centos9-64m-debian11', 0)

        expect(nodes.map { |node| node['ostype'] }).to eq(['centos9'])
      end

      it 'rejects an empty node between delimiters' do
        expect { parse_layout('centos9--64m', 0) }
          .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
      end
    end

    describe 'parse_node_info_token' do
      it 'Raises InvalidNodeSpecError for invalid tokens.' do
        expect { parse_node_info_token('64compile_master') }
          .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
      end

      it 'Supports no roles in the spec.' do
        expect(parse_node_info_token('64'))
          .to eq({
                   'roles' => '',
                   'arbitrary_roles' => [],
                   'bits' => '64',
                   'host_settings' => {},
                 })
      end

      context 'When specifying architecture bits' do
        it 'Supports uppercase alphanumeric architecture bits' do
          expect(parse_node_info_token('SPARC'))
            .to eq({
                     'roles' => '',
                     'arbitrary_roles' => [],
                     'bits' => 'SPARC',
                     'host_settings' => {},
                   })

          expect(parse_node_info_token('POWER6'))
            .to eq({
                     'roles' => '',
                     'arbitrary_roles' => [],
                     'bits' => 'POWER6',
                     'host_settings' => {},
                   })

          expect(parse_node_info_token('S390X'))
            .to eq({
                     'roles' => '',
                     'arbitrary_roles' => [],
                     'bits' => 'S390X',
                     'host_settings' => {},
                   })
        end

        it 'Trailing lowercase characters are parsed as roles' do
          expect(parse_node_info_token('S390Xm'))
            .to eq({
                     'roles' => 'm',
                     'arbitrary_roles' => [],
                     'bits' => 'S390X',
                     'host_settings' => {},
                   })

          expect(parse_node_info_token('S390Xcustom.m'))
            .to eq({
                     'roles' => 'm',
                     'arbitrary_roles' => ['custom'],
                     'bits' => 'S390X',
                     'host_settings' => {},
                   })
        end

        it 'Rejects lowercase characters that are not at the end' do
          expect { parse_node_info_token('AbC3') }
            .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)

          expect { parse_node_info_token('aBC3') }
            .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
        end
      end

      it 'Supports the use of arbitrary roles.' do
        expect(parse_node_info_token('64compile_master,ca,blah.mad'))
          .to eq({
                   'roles' => 'mad',
                   'arbitrary_roles' => %w[compile_master ca blah],
                   'bits' => '64',
                   'host_settings' => {},
                 })
      end

      context 'When using arbitrary roles' do
        it 'Fails without a role-type delimiter (a period)' do
          expect { parse_node_info_token('64compile_master,ca,blah') }
            .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
        end

        it 'supports no static roles.' do
          expect(parse_node_info_token('64compile_master,ca,blah.'))
            .to eq({
                     'roles' => '',
                     'arbitrary_roles' => %w[compile_master ca blah],
                     'bits' => '64',
                     'host_settings' => {},
                   })
        end

        it 'supports digits within role names.' do
          expect(parse_node_info_token('64abc,def6,default.a'))
            .to eq({
                     'roles' => 'a',
                     'arbitrary_roles' => %w[abc def6 default],
                     'bits' => '64',
                     'host_settings' => {},
                   })

          expect(parse_node_info_token('64role_1,r2d2.'))
            .to eq({
                     'roles' => '',
                     'arbitrary_roles' => %w[role_1 r2d2],
                     'bits' => '64',
                     'host_settings' => {},
                   })
        end

        it 'requires each arbitrary role name to start with a lowercase letter.' do
          %w[64_.a 64_1.a 64abc,_1.a 64abc,6def.a].each do |token|
            expect { parse_node_info_token(token) }
              .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
          end
        end

        it 'rejects empty entries in a comma-separated role list.' do
          %w[64,role2.a 64abc,,role2.a 64role2,.a 64,.].each do |token|
            expect { parse_node_info_token(token) }
              .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
          end
        end

        it 'preserves architecture bits when parsing arbitrary roles.' do
          expect(parse_node_info_token('641abc.a'))
            .to include('bits' => '641', 'arbitrary_roles' => ['abc'])
          expect(parse_node_info_token('AARCH64r2d2.m'))
            .to include('bits' => 'AARCH64', 'arbitrary_roles' => ['r2d2'])
          expect(parse_node_info_token('6432role2.a'))
            .to include('bits' => '6432', 'arbitrary_roles' => ['role2'])
        end

        it 'supports lowercase Unicode letters before digits or underscores.' do
          expect(parse_node_info_token('64role_,é2,café_1.'))
            .to include('arbitrary_roles' => %w[role_ é2 café_1])
        end

        it 'rejects non-ASCII letters after a digit or underscore.' do
          %w[64r2é.a 64abc,r_é.a].each do |token|
            expect { parse_node_info_token(token) }
              .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
          end
        end

        it 'rejects non-ASCII digits in role names.' do
          %w[64role２.a 64role٣.a 64role١.a 64abc,role２.a].each do |token|
            expect { parse_node_info_token(token) }
              .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
          end
        end

        it 'requires the role-type delimiter for roles containing digits.' do
          expect { parse_node_info_token('64abc2') }
            .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
        end

        it 'supports numeric role names together with static roles and host settings.' do
          expect(parse_node_info_token('64role2.m{foo=bar}'))
            .to eq({
                     'roles' => 'm',
                     'arbitrary_roles' => ['role2'],
                     'bits' => '64',
                     'host_settings' => { 'foo' => 'bar' },
                   })
        end

        it 'preserves an empty arbitrary role list.' do
          expect(parse_node_info_token('64.'))
            .to eq({
                     'roles' => '',
                     'arbitrary_roles' => [],
                     'bits' => '64',
                     'host_settings' => {},
                   })
        end
      end

      context 'When using arbitrary host settings' do
        it 'Supports arbitrary nested hashes and arrays' do
          expect(parse_node_info_token('64{foo={bar=baz},foo2={bar2=baz2,bar22=baz22},foo3=bar3,foo4=[[bar4],baz4],list=[{map1=map11,map2=map22},{lastmap=lastmap2}]}'))
            .to eq({
                     'roles' => '',
                     'arbitrary_roles' => [],
                     'bits' => '64',
                     'host_settings' =>
                      { 'foo' => { 'bar' => 'baz' },
                        'foo2' => { 'bar2' => 'baz2', 'bar22' => 'baz22' },
                        'foo3' => 'bar3',
                        'foo4' => [['bar4'], 'baz4'],
                        'list' => [{ 'map1' => 'map11', 'map2' => 'map22' }, { 'lastmap' => 'lastmap2' }], },
                   })
        end

        it 'Supports arbitrary whitespace in values' do
          expect(parse_node_info_token('64{k1=value 1,k2=v2,k3=  v3  ,k4=[v4, v5 ,v6]}'))
            .to eq({
                     'roles' => '',
                     'arbitrary_roles' => [],
                     'bits' => '64',
                     'host_settings' => {
                       'k1' => 'value 1',
                       'k2' => 'v2',
                       'k3' => '  v3  ',
                       'k4' => ['v4', ' v5 ', 'v6'],
                     },
                   })
        end

        it 'Raises InvalidNodeSpecError for malformed key-value pairs' do
          expect { parse_node_info_token('64{foo=bar=baz}') }
            .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)

          expect { parse_node_info_token('64{foo=}') }
            .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)

          expect { parse_node_info_token('64{=bar}') }
            .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)

          expect { parse_node_info_token('64{=}') }
            .to raise_error(BeakerHostGenerator::Exceptions::InvalidNodeSpecError)
        end
      end
    end
  end
end
