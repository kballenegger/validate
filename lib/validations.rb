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
      @validations.select do |v|
        # `:when` is a special case, this gets processed right away and
        # filtered out...
        !(v[:opts] || {})[:when].is_a?(Proc) || context.instance_eval(&v[:opts][:when])
      end.map do |v|
        # destructure fields
        v[:fields].map {|f| v.merge(fields: f) }
      end.flatten(1).map do |v|
        # lastly, execute validation
        method = ValidationMethods.instance_method(v[:name])
        args = [v[:fields]]
        if v[:opts]
          opts = v[:opts].dup
          opts.delete(:when) # when doesn't belong in arguments
          args << opts if opts.count > 0
        end

      end.reduce {|a,b| a && b }
    end
  end

  private

  # The rules for parsing validations are such:
  #
  # - Validations are method calls (starting with the string `validates_`)
  # - followed by field names as regular arguments (as symbols)
  # - any options are included in an options hash, eg. is: String
  # - and native blocks are reserved for children-validations
  #
  # For example:
  #
  #   validates_subhash :iap1, :iap2, when: -> { type == :iap } do
  #     validates_type_of :id,   is: String
  #     validates_type_of :tier, is: Numeric
  #   end
  #
  class BlockParsingContext

    def initialize
      @validations = []
    end

    attr_reader :validations

    def method_missing(method, *args, &block)
      raise "Undefined validation #{method}..." unless ValidationMethods.instance_methods(false).include?(method)
      opts = args.pop if args.last.is_a?(::Hash)
      children = if block
        context = BlockParsingContext.new
        context.instance_eval(&block)
        context.validations
      end
      @validations << {
        name: method,
        fields: args,
        opts: opts,
        validations: children
      }
    end
  end


  module ValidationMethods

    def validates_presence_of(obj, field, opts)
      obj.include?(field)
    end
  end

end
