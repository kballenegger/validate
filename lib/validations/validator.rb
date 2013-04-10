
module Validations

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

end
