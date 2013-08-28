require "spec_helper"

describe UserMailer do
  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user, :password_reset_token => "anything") }
    let(:mail) { UserMailer.password_reset(user) }

    it "should send user password reset url" do
      expect(mail.subject).to eq("Password reset")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["a.h.schiller@gmail.com"])
    end

    it "renders the email body" do
      expect(mail.body.encoded).to match(edit_password_reset_path(user.password_reset_token))
    end
  end

  # describe "welcome email" do
  #   let(:user) # user user_pages_spec strategy to define this
  #   let(:mail) { UserMailer.welcome_email(user) }

  #   it "should send user the welcome email" do    
  #     expect { mail.subject }.to eq("Welcome to Thoughtsy!")
  #     mail.to.should eq(["user@example.com"])
  #     mail.from.should eq(["a.h.schiller@gmail.com"])
  #     mail.body.encoded.should match(user_path(user))
  #   end
  # end
end
