require 'spec_helper'

# controller tests used for testing AJAX (XHR - 'XmlHttpRequest')
# xhr :HTTP_method, :action, controller: { hash of parameters }

describe MessagesController do

  let(:user) { FactoryGirl.create(:user) }
  let(:response) { FactoryGirl.create(:response) }

  before { sign_in user, no_capybara: true }

  describe "Message with AJAX" do

    describe "with invalid information" do

      it "does not create a message" do
        expect do
          xhr :post, 'create', message: { user_id: user.id, content: ' ', to_id: response.user.id }
        end.not_to change(Message, :count)
      end
    end

    describe "with valid information" do

      it "increments the message count" do
        expect do
          xhr :post, 
              :create,
              :message => { user_id: user.id, content: 'message', to_id: response.user.id }
        end.to change(Message, :count).by(1)
      end

      it "shows the correct flash message" do
        xhr :post, 'create', message: { user_id: user.id, content: 'message', to_id: response.user.id }
        expect(flash[:success]).to eq "Message sent!"
      end

      it "sends an email" do
        xhr :post, 'create', message: { user_id: user.id, content: 'message', to_id: response.user.id }
        expect(last_email.to).to include(response.user.email)
      end
    end
  end
end