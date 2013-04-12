

require 'kongo'

# This file bridges Kongo and Validate by adding support for a validates?
# method to Kongo::Collection.
#
module Kongo

  class Collection

    # Returns whether `hash` would be a valid model if inserted.
    #
    def validates?(hash)
      hash = hash.dup
      hash['_id'] = BSON::ObjectId.new unless hash.include?('_id')
      model = ::Kongo::Model.new(hash, coll)
      # NOTE: raises NoMethodError if the model does not have validations
      model.validates?
    end
  end
end

