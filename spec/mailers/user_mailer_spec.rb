require "spec_helper"

describe UserMailer do
  describe "password_reset email" do
    let(:user) { FactoryGirl.create(:user, :password_reset_token => "anything") }
    let(:mail) { UserMailer.password_reset(user) }

    it "sends user password reset url" do
      expect(mail.subject).to eq("Password reset")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["Thoughtsy@thoughtsy.com"])
    end

    it "renders the email body" do
      expect(mail.body.encoded).to match(edit_password_reset_path(user.password_reset_token))
    end
  end

  describe "inactive_user_email" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.inactive_user_email(user) }

    it "sends inactive_user_email to user" do
      expect(mail.subject).to eq("Thoughtsy needs you!")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["Thoughtsy@thoughtsy.com"])
    end

    it "renders the email body" do
      expect(mail.body.encoded).to match(root_path)
    end
  end

  describe "response_emails" do
    let(:user) { FactoryGirl.create(:user) }
    let(:post) { FactoryGirl.create(:post, user_id: user.id) }
    let(:responder) { FactoryGirl.create(:user) }
    let(:response) { FactoryGirl.create(:response, user_id: responder.id, post_id: post.id) }

    describe "to poster" do
      let(:mail) { UserMailer.poster_email(user, response) }

      it "sends correct mail" do
        expect(mail.subject).to eq("Someone has responded to your thought!")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq(["Thoughtsy@thoughtsy.com"])
      end

      it "renders the email body" do
        expect(mail.body.encoded).to match(post_path(post))
      end
    end
  end

  describe "message_email" do
    let!(:sender) { FactoryGirl.create(:user) }
    let!(:receiver) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.message_email(@message) }
    before do
      @message = Message.new(user_id: sender.id, receiver_id: receiver.id, content: "hey")
      @message.save
    end

    it "sends message_email to receiver" do
      expect(mail.subject).to eq("#{sender.username} sent you a personal message.")
      expect(mail.to).to eq([receiver.email])
      expect(mail.from).to eq(["Thoughtsy@thoughtsy.com"])
    end

    it "renders the email body" do
      expect(mail.body.encoded).to match(user_path(receiver))
    end
  end

  describe "flag_email" do
    let(:post) { FactoryGirl.create(:post) }
    let(:mail) { UserMailer.flag_email(post) }

    it "sends flag_email to admin" do
      expect(mail.subject).to eq("Thoughtsy: post flagged")
      expect(mail.to).to eq(['a.h.schiller@gmail.com'])
      expect(mail.from).to eq(["Thoughtsy@thoughtsy.com"])
    end

    it "renders the email body" do
      expect(mail.body.encoded).to match(post_path(post))
    end
  end

  describe "brilliant_email" do
    context "from a response" do
      let(:response) { FactoryGirl.create(:response) }
      let(:mail) { UserMailer.brilliant_email(response) }

      it "sends brilliant_email to admin" do
        expect(mail.subject).to eq("Thoughtsy: thought rated 'brilliant'")
        expect(mail.to).to eq(['a.h.schiller@gmail.com'])
        expect(mail.from).to eq(["Thoughtsy@thoughtsy.com"])
      end

      it "renders the email body" do
        expect(mail.body.encoded).to match(post_path(response.post))
      end
    end

    context "from a post" do
      let(:post) { FactoryGirl.create(:post) }
      let(:mail) { UserMailer.brilliant_email(post) }

      it "sends brilliant_email to admin" do
        expect(mail.subject).to eq("Thoughtsy: thought rated 'brilliant'")
        expect(mail.to).to eq(['a.h.schiller@gmail.com'])
        expect(mail.from).to eq(["Thoughtsy@thoughtsy.com"])
      end

      it "renders the email body" do
        expect(mail.body.encoded).to match(post_path(post))
      end
    end
  end
end
