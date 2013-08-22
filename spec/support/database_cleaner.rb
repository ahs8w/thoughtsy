RSpec.configure do |config|

# clear the db completely before beginning tests
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

# default db cleaning strategy is transaction -> fast
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

# for testing of js, selenium fires up a browser window and transactions don't work
  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

# hooks up db cleaner around beginning...
  config.before(:each) do
    DatabaseCleaner.start
  end

# and end of each test.
  config.after(:each) do
    DatabaseCleaner.clean
  end

end