class Post < ActiveRecord::Base
  belongs_to :user

  default_scope -> { order('created_at DESC') }             # scopes take an anonymous function (for 'lazy' evaluation)
  validates_presence_of :user_id, :content
end
