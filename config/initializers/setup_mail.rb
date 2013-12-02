if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :address              => "smtp.mandrillapp.com",
    :port                 => 587,
    :domain               => "heroku.com",
    :user_name            => ENV["MANDRILL_USERNAME"],
    :password             => ENV["MANDRILL_APIKEY"],
    :authentication       => "plain",
    :enable_starttls_auto => true
  }

  ActionMailer::Base.default_url_options = { host: "thoughtsy.com" }
else
  ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "gmail.com",
    :user_name            => ENV["GMAIL_USERNAME"],
    :password             => ENV["GMAIL_PASSWORD"],
    :authentication       => "plain",
    :enable_starttls_auto => true
  }

  ActionMailer::Base.default_url_options = { host: "localhost:3000" }
  require 'development_mail_interceptor'
  ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
end