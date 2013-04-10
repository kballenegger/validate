
module Validations

  # Actual implementation
  #
  class Validator

    def initialize(validations)
      @validations = validations
    end

    def validates?(context)
      @validations
        .select do |v|
          # `:when` is a special case, this gets processed right away and
          # filtered out...
          !(v[:opts] || {})[:when].is_a?(Proc) || context.instance_eval(&v[:opts][:when])
        end
        .map do |v|
          # destructure fields
          v[:fields].map {|f| v.merge(fields: f) }
        end.flatten(1)
        .map do |v|
          # lastly, execute validation
          validator = if v[:validations]
            Validator.new(v[:validations])
          end
          ValidationMethods.send(v[:name], context.to_hash, v[:fields], v[:opts], validator)
        end
        .reduce {|a,b| a && b }
        # return the result as a boolean
    end
  end

end
