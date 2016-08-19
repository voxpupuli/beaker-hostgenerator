module BeakerHostGenerator
  module AbsSupport
    module_function

    def extract_templates(config)
      config['HOSTS'].map do |host, settings|
        "#{settings['template']}=1"
      end.join(',')
    end
  end
end
