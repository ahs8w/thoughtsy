include ApplicationHelper

def sign_in(user, options={})
  if options[:no_capybara]
    # Sign in not using Capybara (not using browser buttons/links)
    # necessary when using HTTP request methods directly
    remember_token = User.new_remember_token        # creates remember token
    cookies[:remember_token] = remember_token       # puts created remember token into browser cookies
    user.update_attribute(:remember_token, User.encrypt(remember_token))  # puts encrypted version in user attributes
  else
    visit signin_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end

def page_info(title)
  let(:heading)    { title }
  let(:page_title) { title }
end

## Mailer methods
def last_email
  ActionMailer::Base.deliveries.last
end

def reset_email
  ActionMailer::Base.deliveries = []
end

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-danger', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-success', text: message)
  end
end

RSpec::Matchers.define :have_info_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-info', text: message)
  end
end

RSpec::Matchers.define :have_warning_message do |message|
  match do |page|
    expect(page).to have_selector('div.alert.alert-warning', text: message)
  end
end