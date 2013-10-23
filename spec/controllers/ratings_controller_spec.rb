require 'spec_helper'

# controller tests used for testing AJAX (XHR - 'XmlHttpRequest')
# xhr :HTTP_method, :action, controller: { hash of parameters }

describe RatingsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:response) { FactoryGirl.create(:response) }

  before do
    user.subscribe!(response.post)
    sign_in user, no_capybara: true
  end

  describe "Rating with AJAX" do

    describe "with invalid information" do

      it "should not create a rating" do
        expect do
          xhr :post, :create, rating: { response_id: response.id, user_id: user.id, value: ' ' }
        end.not_to change(Rating, :count)
      end
    end

    describe "with valid information" do

      it "should increment the Rating count" do
        expect do
          xhr :post, 'create', rating: { response_id: response.id, user_id: user.id, value: '2' }
        end.to change(Rating, :count).by(1)
      end

      it "should show the correct flash message" do
        xhr :post, 'create', rating: { response_id: response.id, user_id: user.id, value: '1' }
        expect(flash[:success]).to eq "Rating saved."
      end
    end
  end
end