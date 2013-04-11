
require 'rspec'

$: << File.dirname(__FILE__) + '/../lib'
require 'validations'



class BaseTestClass
  def initialize(hash)
    @hash = hash
  end
  def to_hash
    @hash
  end
  include Validations
end

describe Validations do

  context 'simple test' do

    before do
      class TestClass < BaseTestClass
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

  context 'validates_presence_of' do
    
    before do
      class TestClass < BaseTestClass
        validations do
          validates_presence_of :field
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: :something)
      test.validates?.should == true
    end

    it 'fails' do
      test = TestClass.new(random: :field_name)
      test.validates?.should == false
    end
  end

  context 'validates_type_of' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_type_of :field, is: Symbol
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: :symbol)
      test.validates?.should == true
    end
    
    it 'fails' do
      test = TestClass.new(field: 'symbol')
      test.validates?.should == false
    end
  end

  context 'validates' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates :field, with: -> { self[:test] == :val }
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: {test: :val})
      test.validates?.should == true
    end
    
    it 'fails' do
      test = TestClass.new(field: {test: nil})
      test.validates?.should == false
    end
  end

  context 'validates_inclusion_of' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_inclusion_of :field, in: %w(one two three)
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: 'two')
      test.validates?.should == true
    end
    
    it 'fails' do
      test = TestClass.new(field: {test: nil})
      test.validates?.should == false
    end
  end

end


