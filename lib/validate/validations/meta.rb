
# This is the sillyness required to implement the DSL for the validations file.
#
# Metaprogramming woooooo, though!
#
module Validate
  class ValidationMethods

    def self.method_added(name)
      return unless @next_reason
      reason = @next_reason
      @next_reason = nil

      (@reasons ||= {})[name.to_s] = reason
    end

    def self.reason(name)
      reason = (@reasons || {})[name.to_s] || "did not validate."
    end

    private
    def self.fails_because_key(reason = nil, &block)
      raise ArgumentError.new('Must provide either a reason string or block.') unless reason || block
      @next_reason = reason || block
    end

    class ArgumentFailureBlockScope
      def initialize(obj, field, opts, validator)
        @obj, @field, @opts, @validator = obj, field, opts, validator
      end
      attr_reader :obj, :field, :opts, :validator 
    end
  end
end
