source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'
# gem 'bootstrap-sass', github: 'thomas-mcdonald/bootstrap-sass'
gem 'faker'
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'state_machine'
gem 'delayed_job_active_record'
gem 'rmagick'
gem 'carrierwave'
gem 'remotipart', '~> 1.2'

gem 'passenger'

# Use sqlite3 as the database for Active Record
group :development, :test do
  gem 'sqlite3'
  gem 'guard-rspec'
  # gem 'guard-livereload', require: false
  gem 'spork-rails', github: 'sporkrb/spork-rails'
  gem 'guard-spork'
  gem 'childprocess'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard', '2.0.5'
end

group :test do
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'libnotify'
  gem 'database_cleaner', '1.0.1'
  gem 'launchy'
  gem 'timecop'
end

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.1'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
