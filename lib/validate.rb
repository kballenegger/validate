require 'validate/version'
require 'validate/validations'
require 'validate/parser'
require 'validate/validator'


module Validate

  module ClassMethods
    # Doubles as setter & getter for @validations
    # This method is also the main interface to this lib.
    #
    def validations(&block)
      return @validator unless block
      validations = BlockParsingContext.parse(&block)
      @validator = Validator.new(validations)
    end
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  # May throw a nil NoMethodError if validations are not defined properly.
  #
  def validates?
    @validator = self.class.validations.dup
    @validator.validates?(self)
  end

  def failures
    return [] unless @validator
    @validator.failures
  end

end
