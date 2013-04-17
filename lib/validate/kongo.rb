require 'kongo'
require 'validate'

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
      model.validates?
    end

    # Returns any failures on `hash` if it were to be inserted.
    #
    def validation_failures(hash)
      hash = hash.dup
      hash['_id'] = BSON::ObjectId.new unless hash.include?('_id')
      model = ::Kongo::Model.new(hash, coll)
      model.validates?
      model.failures
    end
  end

  class Model

    # This is the same as add_extension, but should be used to add validation
    # extensions, which are implemented differently from regular extensions.
    #
    def self.add_validation_extension(collection_name, mod)
      @@validations = mod.validations
      ((@@extensions ||= {})[collection_name.to_sym] ||= []) << mod
    end

    # This method is used by the validations library to fetch the validations
    # to run. Do not call this directly.
    #
    def self.validations
      @@validations
    end
  end
end

