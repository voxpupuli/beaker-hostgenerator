module BeakerHostGenerator
  # Utility functions for supporting CI.next and the AlwaysBeScheduling hypervisor.
  module AbsSupport
    module_function

    # Given an existing, fully-specified host configuration, count the number of
    # hosts using each template, and return a map of template name to host count.
    #
    # For example, given the following config (parts omitted for brevity):
    #    {"HOSTS"=>
    #     {"centos6-64-1"=>
    #        {"template"=>"centos-6-x86_64", ...},
    #      "redhat7-64-1"=>
    #        {"template"=>"redhat-7-x86_64", ...},
    #      "centos6-64-2"=>
    #        {"template"=>"centos-6-x86_64", ...}},
    #     ...
    #    }}
    #
    # Returns the following map:
    #     {"centos-6-x86_64"=>2, "redhat-7-x86_64"=>1}
    #
    def extract_templates(config)
      templates_hosts = config['HOSTS'].values.group_by { |h| h['template'] }
      templates_hosts.each do |template, hosts|
        templates_hosts[template] = hosts.count
      end
    end
  end
end
