require 'spec_helper'

# controller tests used for testing AJAX (XHR - 'XmlHttpRequest')
# xhr :HTTP_method, :action, controller: { hash of parameters }

describe RatingsController do

  let(:user) { FactoryGirl.create(:user) }
  let(:response) { FactoryGirl.create(:response) }
  let(:posting) { FactoryGirl.create(:post) }     # must be different name than post
  before { sign_in user, no_capybara: true }

  describe "#create action" do

    describe "with invalid information" do

      it "should not create a rating" do
        expect do
          xhr :post, 'create', rating: { rateable_id: response.id, rateable_type: 'Response', user_id: user.id, value: ' ' }
        end.not_to change(Rating, :count)
      end
    end

    describe "with valid information" do

      it "should increment the Rating count" do
        expect do
          xhr :post, 'create', rating: { rateable_id: response.id, rateable_type: 'Response', user_id: user.id, value: 3 }
        end.to change(Rating, :count).by(1)
      end

      it "should show the correct flash message" do
        xhr :post, 'create', rating: { rateable_id: posting.id, rateable_type: 'Post', user_id: user.id, value: 3 }
        expect(flash[:success]).to eq "Rating saved."
      end
    end
  end
end