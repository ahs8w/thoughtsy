ActionMailer::Base.smtp_settings = {
  :address              => "smtp.mandrillapp.com",
  :port                 => 587,
  :domain               => "heroku.com",
  :user_name            => ENV["MANDRILL_USERNAME"],
  :password             => ENV["MANDRILL_APIKEY"],
  :authentication       => "plain",
  :enable_starttls_auto => true
}

if Rails.env.production?
  ActionMailer::Base.default_url_options = { host: "thoughtsy.com" }
elsif Rails.env.staging?
  ActionMailer::Base.default_url_options = { host: "thoughtsy-staging.herokuapp.com" }
  require 'development_mail_interceptor'
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor)
else
  ActionMailer::Base.default_url_options = { host: "localhost:3000" }
  require 'development_mail_interceptor'
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
end