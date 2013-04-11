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
    self.class.validations.validates?(self)
  end

end
