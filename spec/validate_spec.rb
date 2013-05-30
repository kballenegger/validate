
require 'rspec'

$: << File.dirname(__FILE__) + '/../lib'
require 'validate'



class BaseTestClass
  def initialize(hash)
    @hash = hash
  end
  def to_hash
    @hash
  end
  include Validate
end

describe Validate do

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

  context 'single failure' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_presence_of 'name'
        end
      end
    end

    it 'should have no failures before running the test' do
      test = TestClass.new({"not_name" => :hello})
      test.failures.should == []
    end

    it 'should have the correct failure array' do
      test = TestClass.new({"not_name" => :hello})
      test.validates?.should == false
      test.failures.should == [{'name'=>'was not present.'}]
    end

    it 'should have an empty failure array when test succeeds' do
      test = TestClass.new({"name" => :hello})
      test.validates?.should == true
      test.failures.should == []
    end

  end

  context 'multiple failures' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_presence_of 'name', reason: -> { 'MUST BE HERE' } # lambda here helps test two things at once
          validates_type_of :something, is: String
        end
      end
    end

    it 'should have the correct failure array' do
      test = TestClass.new({"not_name" => :hello})
      test.validates?.should == false
      test.failures.should == [{'name'=>'MUST BE HERE'}, {:something=>'was not of type String.'}]
    end

  end

  context 'multiple fields' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_presence_of :field1, :field2
        end
      end
    end

    it 'validate' do
      test = TestClass.new(field1: true, field2: true)
      test.validates?.should == true
    end
    
    it 'fail' do
      test = TestClass.new(field1: true)
      test.validates?.should == false
    end
  end

  context 'when option' do
    before do
      class TestClass < BaseTestClass
        validations do
          validates_presence_of :name, when: -> { @hash[:something] == true }
        end
      end
    end

    it 'validates when when does not match' do
      test = TestClass.new(something: false)
      test.validates?.should == true
    end
    
    it 'validates when when does match' do
      test = TestClass.new(something: true, name: 'me')
      test.validates?.should == true
    end
    
    it 'fails' do
      test = TestClass.new(something: true)
      test.validates?.should == false
    end
  end

  context 'when option' do
    before do
      class TestClass < BaseTestClass
        validations do
          validates_type_of :name, is: Symbol, when: :is_set
        end
      end
    end

    it 'validates when when does not match' do
      test = TestClass.new(something: false)
      test.validates?.should == true
    end
    
    it 'validates when when does match' do
      test = TestClass.new(name: :sym)
      test.validates?.should == true
    end
    
    it 'fails' do
      test = TestClass.new(name: 'me')
      test.validates?.should == false
    end
  end

  context 'run_when block' do
    before do
      class TestClass < BaseTestClass
        validations do
          run_when -> { @hash[:something] == true } do
            validates_presence_of :name
            validates_numericality_of :amount
          end
        end
      end
    end

    it 'validates when when does not match' do
      test = TestClass.new(something: false)
      test.validates?.should == true
    end

    it 'validates when when does match' do
      test = TestClass.new(something: true, name: 'me', amount: 1.3)
      test.validates?.should == true
    end

    it 'fails when one validations fail' do
      test = TestClass.new(something: true, name: 'me')
      test.validates?.should == false
    end

    it 'fails when all validations fail' do
      test = TestClass.new(something: true)
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

    it 'passes arguments' do
      class TestClass < BaseTestClass
        validations do
          validates :field, with: ->(o,k) { o[k] == :val }
        end
      end
      test = TestClass.new(field: :val)
      test.validates?.should == true
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

  context 'validates_numericality_of' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_numericality_of :field
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: 1.3)
      test.validates?.should == true
    end
    
    it 'fails' do
      test = TestClass.new(field: {test: nil})
      test.validates?.should == false
    end
  end

  context 'validates_value_of' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_value_of :field, is: :something
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: :something)
      test.validates?.should == true
    end
    
    it 'fails' do
      test = TestClass.new(field: :something_else)
      test.validates?.should == false
    end
  end

  context 'validates_regex' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_regex :field, matches: /^hello/
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: 'hello world')
      test.validates?.should == true
    end
    
    it 'fails' do
      test = TestClass.new(field: 'bye world')
      test.validates?.should == false
    end
  end

  context 'validates_child_hash' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_child_hash :field do
            validates_value_of :type, is: 'price'
            validates_numericality_of :amount
          end
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: {type: 'price', amount: 1.3})
      test.validates?.should == true
    end
    
    it 'fails when not a hash' do
      test = TestClass.new(field: nil)
      test.validates?.should == false
    end

    it 'fails when all validations fail' do
      test = TestClass.new(field: {random: :stuff})
      test.validates?.should == false
    end

    it 'fails when only one validation fails' do
      test = TestClass.new(field: {type: :random, amount: 20})
      test.validates?.should == false
    end
  end


  context 'validates_array' do

    before do
      class TestClass < BaseTestClass
        validations do
          validates_array :field do
            validates_type_of :self, is: String
          end
        end
      end
    end

    it 'validates' do
      test = TestClass.new(field: %w(one two three))
      test.validates?.should == true
    end
    
    it 'fails when not a hash' do
      test = TestClass.new(field: 'not an array')
      test.validates?.should == false
    end

    it 'fails when all validations fail' do
      test = TestClass.new(field: [1, 2, 3])
      test.validates?.should == false
    end

    it 'fails when only one validation fails' do
      test = TestClass.new(field: ['one', 'two', 3])
      test.validates?.should == false
    end
  end


  context 'complex example' do

    before do

      class TestClass < BaseTestClass

        validations do
          validates_type_of :id, is: Integer
          validates_type_of :name, :description, is: String

          validates_presence_of :secret

          validates_inclusion_of :type, in: %w(paid free)

          # validate a block in the data structure that must evaluate to true
          validates :block, with: -> { self.call == true }

          # number_or_symbols is an array that contains either numerics or
          # symbols... only when it is set
          validates_array :number_or_symbols, when: -> { @hash.include?(:number_or_symbols) } do

            validates :self, with: -> { self.is_a?(String) || self.is_a?(Numeric) }

            # when it is numeric, it must be greater than 0
            validates :self,
              when: -> { self[:self].is_a?(Numeric) },
              with: -> { self > 0 }

            # when it is a symbol, it start with `a` and is > 2 chars
            run_when -> { self[:self].is_a?(String) } do
              validates_regex :self, matches: /^a/
              validates_regex :self, matches: /..+/
            end
          end

          validates_child_hash :iap do
            validates_type_of :id, is: Numeric
            validates_type_of :bundle, is: String
            validates_regex :bundle, matches: /(\w+\.){2}\w+/
          end
          validates :iap, with: -> { self.keys.count == 2 }
        end
      end

      @valid_hash = {
        id: 1,
        name: 'item',
        description: 'string',
        secret: :anything,
        type: 'paid',
        block: -> { true },
        number_or_symbols: [
          1, 2, 3,
          'awesome', 'awful'
        ],
        iap: {
          id: 1,
          bundle: 'com.chartboost.awesome'
        }
      }
    end

    it 'validates' do
      test = TestClass.new(@valid_hash)
      test.validates?.should == true
    end

    it 'fails when block is changed' do
      hash = @valid_hash.dup
      hash[:block] = -> { false }
      test = TestClass.new(hash)
      test.validates?.should == false
    end

    it 'fails when number_or_symbols contains invalid numbers' do
      hash = @valid_hash.dup
      hash[:number_or_symbols] = [0, -1, 'awesome']
      test = TestClass.new(hash)
      test.validates?.should == false
    end

    it 'fails when number_or_symbols contains invalid symbols' do
      hash = @valid_hash.dup
      hash[:number_or_symbols] = ['sick', 'awesome', 3, 'awful']
      test = TestClass.new(hash)
      test.validates?.should == false
    end

    it 'fails when secret does not exist' do
      hash = @valid_hash.dup
      hash.delete(:secret)
      test = TestClass.new(hash)
      test.validates?.should == false
    end

    it 'fails when number_or_symbols contains invalid numbers' do
      hash = @valid_hash.dup
      hash[:iap] = {
        id: 1,
        bundle: 'hello'
      }
      test = TestClass.new(hash)
      test.validates?.should == false
    end
  end


  context Hash do

    before do
      require 'validate/hash'
      @compiled_validation = Validate::Parser.parse do
        validates_presence_of 'name', when: -> { true }
      end
    end

    it 'should validate a valid object' do
      hash = {"name" => :hello}
      hash.validates?(@compiled_validation).should == true
      hash.failures.should == []
    end

    it 'should fail to validate an invalid object' do
      hash = {"not_name" => :hello}
      hash.validates?(@compiled_validation).should == false
      hash.failures.should == [{"name"=>"was not present."}]
    end

    it 'should validate a valid object, when compiling on the fly' do
      hash = {"name" => :hello}
      hash.validates? do
        validates_presence_of 'name', when: -> { true }
      end.should == true
      hash.failures.should == []
    end
  end


  context 'when allow_keys' do

    context 'is `:valid`' do

      before do
        class TestClass < BaseTestClass
          validations do
            allow_keys :valid
            validates_type_of 'one', 'two', when: :is_set, is: Symbol
          end
        end
      end

      it 'should validate an object' do
        test = TestClass.new({'one' => :hello})
        test.validates?.should == true
      end

      it 'should not validate an invalid object' do
        test = TestClass.new({'one' => :hello, 'three' => :hello})
        test.validates?.should == false
        test.failures.should == [{'three' => 'is not a valid key.'}]
      end

    end

    context 'is an array' do

      before do
        class TestClass < BaseTestClass
          validations do
            allow_keys %w(one two)
          end
        end
      end

      it 'should validate an object' do
        test = TestClass.new({'two' => :hello})
        test.validates?.should == true
      end

      it 'should not validate an invalid object' do
        test = TestClass.new({'one' => :hello, 'three' => :hello})
        test.validates?.should == false
        test.failures.should == [{'three' => 'is not a valid key.'}]
      end

    end
  end

end

