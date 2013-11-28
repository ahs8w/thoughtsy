# according to www.nicholas-hwang.com/s/4
# fix bug with Rails 4; workless not scaling down dynos after running background job

Delayed::Backend::ActiveRecord::Job.class_eval do
  after_destroy "self.class.scaler.down"
  after_create "self.class.scaler.up"
  after_update "self.class.scaler.down"
end