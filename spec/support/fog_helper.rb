Fog.mock!

def fog_directory
  ENV['FOG_DIRECTORY']
end

connection = ::Fog::Storage.new(
  :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
  :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
  :provider               => 'AWS'
)

connection.directories.create(:key => fog_directory)

# Fog.credentials_path = Rails.root.join('config/fog_credentials.yml')
# connection = Fog::Storage.new(:provider => 'AWS')
# connection.directories.create(:key => "https://thoughtsy-production")