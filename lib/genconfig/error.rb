module GenConfig
  module Errors
    class Error < RuntimeError ; end
    class InvalidNodeSpecError < GenConfig::Errors::Error ; end
  end
end
