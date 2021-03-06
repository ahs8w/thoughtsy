CarrierWave.configure do |config|
  # Fog.credentials_path = Rails.root.join('config/fog_credentials.yml')

  config.fog_credentials = {
    :provider               => ENV['FOG_PROVIDER'],             # required
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],        # required
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],    # required
    :region                 => 'us-east-1'
  }

  config.fog_directory  = ENV['FOG_DIRECTORY']
  
  if Rails.env.test?
    # config.storage = :file
    config.enable_processing = false
  # autoload image uploader
    ImageUploader
  end

  config.cache_dir = "#{Rails.root}/tmp/uploads/#{Rails.env}"     # allows carrierwave to work on heroku
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
  config.min_file_size             = 5.kilobytes                  # defaults to 1.byte
  config.upload_expiration         = 1.hour                       # defaults to 10.hours
end