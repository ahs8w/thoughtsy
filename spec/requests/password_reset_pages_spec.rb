require 'spec_helper'

describe "PasswordResets" do
## Tests taken from Railscasts episode 275

  it "emails user when requesting password reset" do
    user = FactoryGirl.create(:user)
    visit signin_path
    click_link "password"
    fill_in "Email", with: user.email
    click_on "Reset password"
    expect(page).to have_content("Email sent")
    expect(last_email.to).to include(user.email)
  end

  it "does not email invalid user when requesting password reset" do
    visit signin_path
    click_link "password"
    fill_in "Email", with: "fake@example.com"
    click_on "Reset password"
    expect(page).to have_content("not found")
    expect(last_email).to be_nil
  end

  it "updates user password when confirmation matches" do
    user = FactoryGirl.create(:user, password_reset_token: "something",
                                     password_reset_sent_at: 1.hour.ago)
    visit edit_password_reset_path(user.password_reset_token)
    fill_in "Password", with: "foobar"
    click_button "Update Password"
    expect(page).to have_content("Password confirmation doesn't match Password")
    fill_in "Password", with: "foobar"
    fill_in "Password confirmation", with: "foobar"
    click_button "Update Password"
    expect(page).to have_content("Password has been reset")
  end

  it "reports when password token has expired" do
    user = FactoryGirl.create(:user, password_reset_token: "something",
                                     password_reset_sent_at: 5.hours.ago)
    visit edit_password_reset_path(user.password_reset_token)
    fill_in "Password", with: "foobar"
    fill_in "Password confirmation", with: "foobar"
    click_button "Update Password"
    expect(page).to have_content("Password reset has expired")
  end

  it "raises record not found when password token is invalid" do
    expect do
      visit edit_password_reset_path("invalid")
    end.to raise_exception(ActiveRecord::RecordNotFound)
  end
end
