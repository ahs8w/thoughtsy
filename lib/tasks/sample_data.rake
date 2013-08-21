namespace :db do                    # allows us to call 'rake db:populate' -> to populate our db
  desc "Fill database with sample data"
  task populate: :environment do    # ensures that rake has access to local environment (e.g. User.create!)
    User.create!(username: "Example User",
                 email: "example@railstutorial.org",
                 password: "foobar",
                 password_confirmation: "foobar",
                 admin: true)
    99.times do |n|
      username = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "foobar"
      User.create!(username: username,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
    users = User.all(limit: 6)
    50.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.posts.create!(content: content) }
    end
  end
end