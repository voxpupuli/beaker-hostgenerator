module GenConfig
  module Utils
    def pe_dir(version, family)
      # If our version is the same as our family, we're installing a
      # released version. Use the archive path. Otherwise, we want to use
      # the development build path.
      if version && family
        if version == family
          return "http://enterprise.delivery.puppetlabs.net/archives/releases/#{family}/"
        else
          return "http://enterprise.delivery.puppetlabs.net/#{family}/ci-ready"
        end
      end
    end

    def deep_copy(object)
      # I feel so dirty
      Marshal.load(Marshal.dump(object))
    end

    def fixup_node(cfg)
      # PE 2.8 doesn't exist for EL 4. We use 2.0 instead.
      if cfg['platform'] =~ /el-4/ and PE_VERSION =~ /2\.8/
        cfg['pe_ver'] = "2.0.3"
      end
    end
  end
end
