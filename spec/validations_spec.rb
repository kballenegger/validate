
require 'rspec'

$: << File.dirname(__FILE__) + '/../lib'
require 'validations'

describe Validations do

  context 'simple test' do

    before do
      class TestClass
        def initialize(hash)
          @hash = hash
        end
        def to_hash
          @hash
        end
        include Validations
        validations do
          validates_presence_of 'name', when: -> { true }
        end
      end
    end

    it 'should validate a valid object' do
      test = TestClass.new({"name" => :hello})
      test.validates?.should == true
    end

    it 'should fail to validate an invalid object' do
      test = TestClass.new({"not_name" => :hello})
      test.validates?.should == false
    end

  end

end


