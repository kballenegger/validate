
module Validate

  # Actual implementation
  #
  class Validator

    def initialize(validations)
      @validations = validations
    end

    def validates?(context)
      bool = @validations
        .map do |v|
          # destructure fields
          v[:fields].map {|f| v.merge(fields: f) }
        end.flatten(1)
        .select do |v|
          # `:when` is a special case, this gets processed right away and
          # filtered out...
          when_opt = (v[:opts] || {})[:when]
          # :is_set is short for checking if then field is set
          when_opt = -> { self.to_hash.include?(v[:fields]) } if when_opt == :is_set
          !when_opt.is_a?(Proc) || context.instance_exec(&when_opt)
        end
        .map do |v|
          # lastly, execute validation
          validator = if v[:validations]
            Validator.new(v[:validations])
          end
          ValidationMethods.send(v[:name], context.to_hash, v[:fields], v[:opts], validator)
        end
        .reduce {|a,b| a && b }
        # return the result as a boolean
      bool.nil? ? true : bool
    end
  end

end
