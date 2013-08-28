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
end
