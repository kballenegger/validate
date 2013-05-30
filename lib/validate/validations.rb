
require 'validate/validations/meta'
module Validate

  # Every validation method has four arguments:
  #
  #   obj:        the `to_hash` of the object to validate
  #   field:      the field to validate
  #   opts:       the options for the validation
  #   validator:  a Validator object that can be used for children
  #
  class ValidationMethods

    # Validate a field by executing a block in the context of the field.
    #
    # `self` in the block is bound to the field's value, or `nil`.
    #
    #   validates :type, with: -> { is_a?(String) && self =~ /^a/ }
    #
    fails_because_key 'failed to match a custom validation.'
    def validates(obj, field, opts, validator)
      args = [obj, field].first(opts[:with].arity)
      true == obj[field].instance_exec(*args, &opts[:with])
    end

    # Validates that a field exists.
    #
    # `nil` is acceptable as a value for the field.
    #
    #   validates_presence_of :field
    #
    fails_because_key 'was not present.'
    def validates_presence_of(obj, field, opts, validator)
      obj.include?(field)
    end

    # Validates that a field exists and is an instance of a class or module.
    #
    #   validates_type_of :name, is: String
    #
    fails_because_key { "was not of type #{opts[:is]}." }
    def validates_type_of(obj, field, opts, validator)
      obj.include?(field) && obj[field].is_a?(opts[:is])
    end

    # Validates that the value of the field appears in an array.
    #
    #   validates_inclusion_of :type, in: %w(paid free)
    #
    fails_because_key { "was not of in #{opts[:in].inspect}." }
    def validates_inclusion_of(obj, field, opts, validator)
      opts[:in].include?(obj[field])
    end

    # Validates that a field's value is numeric.
    #
    #   validates_numericality_of :amount
    #
    fails_because_key 'was not Numeric.'
    def validates_numericality_of(obj, field, opts, validator)
      obj[field].is_a?(Numeric)
    end

    # Validates the value, ensure equality.
    #
    #   validates_value_of :field, is: 'something'
    #
    fails_because_key { "was not #{opts[:is].inspect}." }
    def validates_value_of(obj, field, opts, validator)
      obj.include?(field) && obj[field] == opts[:is]
    end

    # Validates a Hash field with its own set of validations.
    #
    #   validates_child_hash :hash do
    #     validates_value_of :type, is: 'price'
    #     validates_numericality_of :amount
    #   end
    #
    fails_because_key { ['failed validation with errors:', validator.failures] }
    def validates_child_hash(obj, field, opts, validator)
      return false unless obj[field].respond_to?(:to_hash)
      hash = obj[field].to_hash
      validator.validates?(hash)
    end

    # Validates each element in an Array with a set of validations.
    #
    # *Note:* the children validations should look at the field `:self` to
    # contain the value to be validated. ie. it validates {self: element}
    #
    #   # ensures :elements is an array of strings
    #   validates_array :elements do
    #     validates_type_of :self, is: String
    #   end
    #
    fails_because_key 'contained at least one element which failed validation.'
    def validates_array(obj, field, opts, validator)
      return false unless obj[field].respond_to?(:to_a)
      array = obj[field].to_a
      array.map do |e|
        validator.validates?({self: e})
      end.reduce {|a,b| a && b }
    end

    # Validates a field against a regular expression.
    #
    #  validates_regex :field, matches: /^hello/
    #
    fails_because_key { "did not match regex #{opts[:matches].inspect}." }
    def validates_regex(obj, field, opts, validator)
      return false unless obj[field].respond_to?(:=~)
      0 == (obj[field] =~ opts[:matches])
    end

  end

end
