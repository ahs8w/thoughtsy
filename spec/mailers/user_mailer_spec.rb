require "spec_helper"

describe UserMailer do
  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user, :password_reset_token => "anything") }
    let(:mail) { UserMailer.password_reset(user) }

    it "should send user password reset url" do
      expect(mail.subject).to eq("Password reset")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["admin@thoughtsy.com"])
    end

    it "renders the email body" do
      expect(mail.body.encoded).to match(edit_password_reset_path(user.password_reset_token))
    end
  end

  describe "post_email" do
    let(:responder) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.post_email(responder) }

    it "should send post_email to the responder" do
      expect(mail.subject).to eq("Thoughtsy needs you!")
      expect(mail.to).to eq([responder.email])
      expect(mail.from).to eq(["admin@thoughtsy.com"])
    end

    it "renders the email body" do
      expect(mail.body.encoded).to match(root_path)
    end
  end

  describe "response_email" do
    let(:poster) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.response_email(poster) }

    it "should send response_email to the poster" do
      expect(mail.subject).to eq("Someone has responded to your thought!")
      expect(mail.to).to eq([poster.email])
      expect(mail.from).to eq(["admin@thoughtsy.com"])
    end

    # it "renders the email body" do
    #   expect(mail.body.encoded).to match()
    # end
  end
end
