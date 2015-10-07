module Beaker
  module Host
    module Generator
      module Errors
        class Error < RuntimeError ; end
        class InvalidNodeSpecError < Beaker::Host::Generator::Errors::Error ; end
      end
    end
  end
end
