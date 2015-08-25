require 'spec_helper'

class ClassMixedWithDSLHelpers
  include BeakerTemplate::Helpers

  def logger
    RSpec::Mocks::Double.new('logger').as_null_object
  end

end

describe ClassMixedWithDSLHelpers do

  describe 'release conditions' do

    it 'has set the version number from the original template' do
      expect( BeakerTemplate::Version::STRING ).to_not be === '0.0.1rc0'
    end

  end
end