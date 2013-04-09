require 'validations/version'


module Validations

  module ClassMethods
    # Doubles as setter & getter for @validations
    # This method is also the main interface to this lib.
    #
    def validations(&block)
      return @validations unless block
      @validations = Validator.new(block)
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  # May throw a nil NoMethodError if validations are not defined properly.
  #
  def validates?
    self.class.validations.validates?(self)
  end


  # Actual implementation
  #
  class Validator

    def self.parse_block(&block)
      # execute block, return array of validation methods called
    end

    def initialize(block)
      @block = block
    end

    def validates?(context)
      true
    end
  end

  class Context

    def initialize(context)
      @context = context
    end

    # def a method for each validation
  end

end
