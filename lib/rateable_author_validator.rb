class RateableAuthorValidator < ActiveModel::Validator
  def validate(record)
    rateable = record.rateable
    if record.user_id == rateable.user_id
      record.errors[:base] << "You cannot rate your own thought"
    end
  end
end

# must be 'required' in initializers folder (files there are automatically initialized) or application.rb
# added a custom_validators file to initializers folder to require this validator