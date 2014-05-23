require 'kenji'
require 'validate'
require 'validate/hash'

# This extention provides an easier way to utilize Validate's functionality
# from the Kenji web framework.
#
# For example, one might do:
#
#   # a kenji route
#   post '/login' do
#     input = kenji.validated_input do
#       validates_type_of 'email', is: String
#       validates_type_of 'password', is: String
#     end
#     # from here on out I can assume input is valid...
#   end
#
module Kenji
  
  class Kenji

    # This method takes a validations block. The request input is grabbed from
    # Kenji, and tested against the validations. In case the validations fail,
    # the request is aborted and returns with a 400 error.
    #
    # Note: the validations will be parsed each time, which is a little bit
    # inefficient. TODO: fix this.
    #
    def validated_input(&block)
      validations = Validate::Parser.parse(&block)
      input = self.input_as_json
      unless input.validates?(validations)
        self.respond(400, 'Invalid input.', failures: input.failures)
      end
      input
    end
  end
end
