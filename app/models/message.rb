class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :receiver, class_name: 'User', foreign_key: :to_id

  validates_presence_of :user_id, :content, :to_id  
end
