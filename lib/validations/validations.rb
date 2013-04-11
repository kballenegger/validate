
module Validations

  # Every validation method has four arguments:
  #
  #   obj:          the `to_hash` of the object to validate
  #   field:        the field to validate
  #   opts:         the options for the validation
  #   validations:  a Validator object that can be used for children
  #
  module ValidationMethods

    # Validate a field by executing a block in the context of the field.
    #
    # `self` in the block is bound to the field's value, or `nil`.
    #
    #   validates :type, with: -> { is_a?(String) && self =~ /^a/ }
    #
    def self.validates(obj, field, opts, validations)
      true == obj[field].instance_exec(opts[:with])
    end

    # Validates that a field exists.
    #
    # `nil` is acceptable as a value for the field.
    #
    #   validates_presence_of :field
    #
    def self.validates_presence_of(obj, field, opts, validations)
      obj.include?(field)
    end

    # Validates that a field exists and is an instance of a class or module.
    #
    #   validates_type_of :name, is: String
    #
    def self.validates_type_of(obj, field, opts, validations)
      obj.include?(field) && obj[field].is_a?(opts[:is])
    end

    # Validates that the value of the field appears in an array.
    #
    #   validates_inclusion_of :type, in: %w(paid free)
    #
    def self.validates_inclusion_of(obj, field, opts, validations)
      opts[:in].include?(obj[field])
    end

    # Validates that a field's value is numeric.
    #
    #   validates_numericality_of :amount
    #
    def self.validates_numericality_of(obj, field, opts, validations)
      obj[field].is_a?(Numeric)
    end

    # Validates the value, ensure equality.
    #
    #   validates_value_of :field, is: 'something'
    #
    def self.validates_value_of(obj, field, opts, validations)
      obj.include?(field) && obj[field] == opts[:is]
    end

  end

end
