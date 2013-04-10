
module Validations

  module ValidationMethods

    def validates_presence_of(obj, field, opts)
      obj.include?(field)
    end
  end

end
