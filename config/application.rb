require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
# Bundler.require(:default, Rails.env)
# *Changed to add :asset group ~> http://www.stormconsultancy.co.uk/blog/development/
# how-to-get-more-bang-for-your-heroku-buck-while-making-your-rails-site-super-snappy-redux/
Bundler.require(*Rails.groups(:assets => %w(development test), :production => %w(production staging)))

module Thoughtsy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.enforce_available_locales = false

    # make bootstrap-sass compatible to asset pipeline
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)

    # Enable the asset pipeline
    config.assets.enabled = true

    # configuring an external font
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # necessary for heroku to serve background image file (Do not precompile assets!)
    config.assets.initialize_on_precompile = false

    # For securing sensitive information, put it in application.yml (don't forget to gitignore it)
    # Load application.yml in dev environment
    # Will need to be set manually on the command-line for production(Heroku)!!!

    # see:  http://strandcode.com/2013/08/11/security-is-a-feature-9-newb-friendly-steps-to-secure-your-rails-apps/
    # needed to add all environments for testing of carrierwave_direct!!!
    unless Rails.env.production? || Rails.env.staging?
      ENV.update YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))
    end
  end
end
