module BeakerHostGenerator
  # Utility functions for supporting CI.next and the AlwaysBeScheduling hypervisor.
  module AbsSupport
    module_function

    # Given an existing, fully-specified host configuration, extract only the
    # template values from each host and return them as a comma-separated
    # string such as: "centos-6-x86_64=1,redhat-7-x86_64=1"
    def extract_templates(config)
      config['HOSTS'].map do |host, settings|
        "#{settings['template']}=1"
      end.join(',')
    end
  end
end
