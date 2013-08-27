require "spec_helper"

describe UserMailer do
  # describe "password_reset" do
  #   let(:user) { Factory(:user, :password_reset_token => "anything") }
  #   let(:mail) { UserMailer.password_reset(user) }

  #   it "should send user password reset url" do
  #     mail.subject.should eq("Password reset")
  #     mail.to.should eq([user.email])
  #     mail.from.should eq(["from@example.com"])
  #     mail.body.encoded.should match(edit_password_reset_path(user.password_reset_token))
  #   end
  # end

  describe "welcome email" do
    let(:user) # user user_pages_spec strategy to define this
    let(:mail) { UserMailer.welcome_email(user) }

    it "should send user the welcome email" do    
      expect { mail.subject }.to eq("Welcome to Thoughtsy!")
      mail.to.should eq(["user@example.com"])
      mail.from.should eq(["a.h.schiller@gmail.com"])
      mail.body.encoded.should match(user_path(user))
    end
  end
end
