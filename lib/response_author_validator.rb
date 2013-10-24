class ResponseAuthorValidator < ActiveModel::Validator
  def validate(record)
    response = Response.find(record.response_id)
    if record.user_id == response.user_id
      record.errors[:base] << "You cannot rate your own response"
    end
  end
end

# must be 'required' in initializers folder (files there are automatically initialized) or application.rb
# added a custom_validators file to initializers folder to require this validator