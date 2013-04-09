require 'validations/version'


module Validations

  module ClassMethods
    # Doubles as setter & getter for @validations
    # This method is also the main interface to this lib.
    #
    def validations(&block)
      return @validations unless block
      @validations = ValidationsImpl.new(block)
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
  class ValidationsImpl

    def initialize(block)
      @block = block
    end

    def validates?(context)
      true
    end
  end

end
