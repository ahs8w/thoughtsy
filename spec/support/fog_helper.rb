Fog.credentials_path = Rails.root.join('config/fog_credentials.yml')
connection = Fog::Storage.new(:provider => 'AWS')
connection.directories.create(:key => "thoughtsy-aws-s3")

RSpec.configure do |config|
  config.before(:each) do
    Fog.mock!
    Fog::Mock.reset
  end
end