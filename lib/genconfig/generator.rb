require 'genconfig/util'
require 'genconfig/data'

require 'beaker/options/options_hash'

require 'yaml'
require 'json'

module GenConfig
  class Generator
    include GenConfig::Data
    include GenConfig::Utils

    def self.create( hypervisor_type )

      hclass = case hypervisor_type
      when /vsphere/
        GenConfig::VSphere
      when /vagrant/
        GenConfig::Vagrant
      else
        raise "Invalid hypervisor #{type}"
      end

      hclass.new Beaker::Options::OptionsHash.new
    end

    def generate( tokens )
      nodeid = 1
      ostype = tokens[0]
      tokens = tokens.drop(1)

      tokens.each do |toke|
        node_info = NODE_REGEX.match(toke)
        node_info = {
          'bits' => node_info['bits'],
          'roles' => node_info['roles'],
          'ostype' => ostype,
          'nodeid' => nodeid,
        }

        host_name, host_config = generate_node node_info

        if PE_USE_WIN32 && ostype =~ /windows/ && node_info['bits'] == "64"
          host_config['install_32'] = true
        end

        @config['HOSTS'][host_name] = host_config
        nodeid += 1
      end

      # Because a Beaker::Options::OptionsHash dump straight to yaml leaves in
      # class metadata for each enclosed Beaker::Options::OptionsHash, we first
      # have to dump it as json (because Beaker::Options::OptionsHash already
      # has json support so why the hell not??). So we dump to json, load back a
      # Ruby Hash now that we done with the recursive merge of
      # Beaker::Options::OptionsHash, then dump that to_yaml using the yaml
      # library's monkey patch. Whew.
      #
      config = @config.dump
      config = JSON.load(config)
      return config.to_yaml
    end

    def generate_node
      raise "Method 'generate' not implemented!"
    end

  end
end

require 'genconfig/generator/vsphere'
