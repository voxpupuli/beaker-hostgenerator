module BeakerTemplate
  module Helpers

    # include your helper methods here as simple method definitions
    def first
      hosts.each do |host|
        on host, 'whoami'
      end

    end

  end
end