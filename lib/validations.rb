require 'validations/version'


module Validations

  module ClassMethods
    # Doubles as setter & getter for @validations
    # This method is also the main interface to this lib.
    #
    def validations(&block)
      return @validations unless block
      @validations = Validator.new(&block)
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
      context = BlockParsingContext.new
      context.instance_eval(&block)
      context.validations
    end

    def initialize(&block)
      @validations = self.class.parse_block(&block)
    end

    def validates?(context)
      p @validations
    end
  end

  private

  class BlockParsingContext < BasicObject

    def initialize
      @validations = []
    end

    attr_reader :validations

    def method_missing(method, *args, &block)
      raise "Undefined validation #{method}..." unless ValidationContext.method_defined?(method)
      opts = args.pop if args.last.is_a?(::Hash)
      @validations << {
        name: method,
        args: args,
        opts: opts,
        block: block
      }
    end
  end

  class ValidationContext < BasicObject

    def initialize(context)
      @context = context
    end
    
    def context_eval(&block)
      @context.instance_eval(&block)
    end

    # def a method for each validation
    def validates_presence_of(key)
      @context.include?(key)
    end
  end

end
