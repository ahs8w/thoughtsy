class Message < ActiveRecord::Base
  belongs_to :user, inverse_of: :messages

  validates_presence_of :user_id, :content, :to_id  
end
