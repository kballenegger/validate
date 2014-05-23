
module Validate

  # Actual implementation
  #
  class Validator

    def initialize(compiled_validations)
      @validations = compiled_validations.validations
      @allow_keys = compiled_validations.allow_keys
    end

    # TODO: this method could use some cleaning up...
    #
    def validates?(context)
      context_hash = context.to_hash

      @failures = @validations
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
          # fetch reasons
          {reason: (v[:opts] || {})[:reason] || ValidationMethods.reason(v[:name])}.merge(v)
        end
        .reduce({}) do |a,v|
          # group validations by key
          a[v[:fields]] ||= []
          a[v[:fields]] << v
          a
        end
        .map do |_, vs|
          # lastly, execute validation
          catch(:ValidateFailure) do
            vs.each do |v|
              validator = if v[:validations]
                Validator.new(v[:validations])
              end
              success = ValidationMethods.new.send(v[:name], context_hash, v[:fields], v[:opts], validator)
              unless success
                reason = v[:reason].is_a?(Proc) ?
                  ValidationMethods::ArgumentFailureBlockScope.new(context_hash, v[:fields], v[:opts], validator).instance_exec(&v[:reason]) :
                  v[:reason]
                # after one failure for a field, do not execute further
                # validations
                throw(:ValidateFailure, {v[:fields] => reason})
              end
            end
            nil
          end
        end.select {|v| !v.nil? } # discard successes

      if @allow_keys != :any
        allow_keys = if @allow_keys == :valid 
          @validations.map {|v| v[:fields]}.flatten
        else
          @allow_keys
        end
        @failures.push(*(context_hash.keys - allow_keys).map {|k| {k => 'is not a valid key.'} })
      end

      @failures.count == 0
    end

    def failures
      @failures || []
    end
  end

end
