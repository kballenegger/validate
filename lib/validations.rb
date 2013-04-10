require 'validations/version'
require 'validations/validations'
require 'validations/parser'
require 'validations/validator'


module Validations

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
