module BeakerHostGenerator
  module Exceptions
    class Error < RuntimeError ; end
    class InvalidNodeSpecError < BeakerHostGenerator::Exceptions::Error ; end
    class SafeEarlyExit < SystemExit ; end
  end
end
