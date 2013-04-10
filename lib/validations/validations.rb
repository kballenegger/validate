
module Validations

  # Every validation method has four arguments:
  #
  #   obj:          the object to validate
  #   field:        the field to validate
  #   opts:         the options for the validation
  #   validations:  any children validations
  #
  module ValidationMethods

    def validates_presence_of(obj, field, opts, validations)
      obj.include?(field)
    end
  end

end
