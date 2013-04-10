
module Validations

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

    def self.parse(&block)
      # execute block, return array of validation methods called
      context = BlockParsingContext.new
      context.instance_eval(&block)
      context.validations
    end

    def initialize
      @validations = []
    end

    attr_reader :validations

    def method_missing(method, *args, &block)
      raise "Undefined validation #{method}..." unless ValidationMethods.instance_methods(false).include?(method)
      opts = args.pop if args.last.is_a?(::Hash)
      children = if block
        BlockParsingContext.parse(&block)
      end
      @validations << {
        name: method,
        fields: args,
        opts: opts,
        validations: children
      }
    end
  end
end

