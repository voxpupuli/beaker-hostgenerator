module BeakerHostGenerator
  module Errors
    class Error < RuntimeError ; end
    class InvalidNodeSpecError < BeakerHostGenerator::Errors::Error ; end
    class SafeEarlyExit < BeakerHostGenerator::Errors::Error ; end
  end
end
