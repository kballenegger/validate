
module Validations

  # Every validation method has four arguments:
  #
  #   obj:          the `to_hash` of the object to validate
  #   field:        the field to validate
  #   opts:         the options for the validation
  #   validations:  a Validator object that can be used for children
  #
  module ValidationMethods

    def self.validates_presence_of(obj, field, opts, validations)
      obj.include?(field)
    end
  end

end
