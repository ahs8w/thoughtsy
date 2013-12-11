desc "check response expirations is called by the Heroku scheduler add-on"
task :check_response_expirations => :environment do
  puts "Checking pending posts for expiration..."
  Post.check_expirations
  puts "Expiration checks complete."
end