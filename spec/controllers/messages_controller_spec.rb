require 'spec_helper'

# controller tests used for testing AJAX (XHR - 'XmlHttpRequest')
# xhr :HTTP_method, :action, controller: { hash of parameters }

describe MessagesController do

  let(:user) { FactoryGirl.create(:user) }
  let(:receiver) { FactoryGirl.create(:user) }

  before { sign_in user, no_capybara: true }

  describe "::Create sans AJAX" do
    context "with valid attributes" do
      it "creates a new message" do
        expect do
          post :create, message: { user_id: user.id, content: 'message', receiver_id: receiver.id }
        end.to change(Message, :count).by(1)
      end

      it "redirects to home after save" do
        post :create, message: { user_id: user.id, content: 'message', receiver_id: receiver.id }
        expect(response).to redirect_to root_url
      end
    end
    ## context 'with invalid attributes' -> using AJAX
  end

  describe "::create with AJAX" do

    describe "with invalid information" do

      it "does not save a message" do
        expect do
          xhr :post, 'create', message: { user_id: user.id, content: ' ', receiver_id: receiver.id }
        end.not_to change(Message, :count)
      end
    end

    describe "with valid information" do

      it "saves a message" do
        expect do
          xhr :post, 
              :create,
              :message => { user_id: user.id, content: 'message', receiver_id: receiver.id }
        end.to change(Message, :count).by(1)
      end

      it "shows the correct flash message" do
        xhr :post, 'create', message: { user_id: user.id, content: 'message', receiver_id: receiver.id }
        expect(flash[:success]).to eq "Note sent!"
      end

      it "sends an email" do
        xhr :post, 'create', message: { user_id: user.id, content: 'message', receiver_id: receiver.id }
        Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
        expect(last_email.to).to include(receiver.email)
      end
    end
  end
end