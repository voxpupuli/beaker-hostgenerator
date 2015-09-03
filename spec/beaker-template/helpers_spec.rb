require 'spec_helper'

class ClassMixedWithDSLHelpers
  include Beaker::DSL::Helpers::Template

  def logger
    RSpec::Mocks::Double.new('logger').as_null_object
  end

end

describe ClassMixedWithDSLHelpers do

  describe 'release conditions' do

    it 'has updated the version number from the original template' do
      expect( Beaker::DSL::Helpers::Template::Version::STRING ).to_not be === '0.0.1rc0'
    end

  end
end