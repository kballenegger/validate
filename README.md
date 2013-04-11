# Validations

Validations is a validations library that can validate *any* object that can be
converted to a hash using `to_hash`.

## Installation

Add this line to your application's Gemfile:

    gem 'validations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install validations

## Usage

This is what a validation look like, with this library:

```ruby
# Here, we have a custom DSL for expressing validations. We put the
# validations for the model in an extension which we require
# independently. Doing `include Validations` in the module adds
# the required method to make the DSL work, and adds a `validates`
# method which will perform the validations are return whether they
# pass, or whether there are any errors.

module Store
  
  module ItemValidations
    
    # Order matters, first include library. Also: validations are
    # executed and checked in the order in which they are defined.
    include Validations
    
    # Validations are contained within a block, so as to not pollute
    # the class namespace with a DSL's implementation.
    validations do
      
      # simple ActiveRecord style validation
      validates_presence_of :name
      
      # multiple keys can be included in one validation
      validates_type_of :description, :long_description, is: String
      
      # or the key could be validated with a block
      validates :type, with: -> { ['currency', 'iap'].include?(self) }
      
      # or we could build a validation for enums
      validates_inclusion_of :reward_type, in: %w(currency consumable permanent)
      
      # inline `when`, validation only performed when block returns true
      validates_numericality_of :amount, when: -> { type == :currency }
      validates_type_of :currency, is: String, when: -> { type == :currency }
      
      # or alternatively `when` as a block
      when -> { type == :currency } do
        validates_numericality_of :amount
        validates_type_of :currency, is: String
      end
      
      # also, validates subdocuments
      validates_child_hash :iap, when: -> { type == :iap } do
        # the validation is now scoped to the subdocument,
        # ie. we're validating the sub-doc
        validates_type_of :id,      is: BSON::ObjectId
        validates_type_of :iap_id,  is: String
        validates_type_of :tier,    is: Numeric
      end
      
      # arrays can be validated, too:
      validates_array :tags do
        # use regular validate function with the key self to
        # validate array elements
        validates_type_of :self, is: String
      end
      
      # arrays of hashes can be validated by just adding regular
      # validations inside the block
      validates_array :logic do
        validates_inclusion_of :type, in: [:one, :two]
        validates_type_of :one, is: String, when: -> { type == :one }
      end
    end
  end
  ::Kongo::Model.add_extension(:store_items, ItemValidations)

end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
