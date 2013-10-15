require 'spec_helper'

# controller tests used for testing AJAX (XHR - 'XmlHttpRequest')
# xhr :HTTP_method, :action, controller: { hash of parameters }

describe MessagesController do

  let(:user) { FactoryGirl.create(:user) }
  let(:response) { FactoryGirl.create(:response) }

  before { sign_in user, no_capybara: true }

  describe "POST #create sans AJAX" do
    context "with valid attributes" do
      it "creates a new message" do
        expect do
          post :create, message: { user_id: user.id, content: 'message', to_id: response.user.id }
        end.to change(Message, :count).by(1)
      end

      it "redirects to home after save" do
        post :create, message: { user_id: user.id, content: 'message', to_id: response.user.id }
        expect(response).to redirect_to root_url
      end
    end
    ## context 'with invalid attributes' -> using AJAX
  end

  describe "POST #create with AJAX" do

    describe "with invalid information" do

      it "does not save a message" do
        expect do
          xhr :post, 'create', message: { user_id: user.id, content: ' ', to_id: response.user.id }
        end.not_to change(Message, :count)
      end
    end

    describe "with valid information" do

      it "saves a message" do
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