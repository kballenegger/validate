
require 'validate'

class Hash

  # Validates the hash using either a pre-compiled validation, or by parsing
  # the block passed.
  #
  def validates?(validations=nil, &block)
    validations = ::Validate::Parser.parse(&block) unless validations
    @validator = ::Validate::Validator.new(validations)
    @validator.validates?(self)
  end

  # Returns any failures from the last run validations.
  #
  def failures
    return [] unless @validator
    @validator.failures
  end
end
