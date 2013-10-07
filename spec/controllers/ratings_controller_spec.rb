require 'spec_helper'

# controller tests used for testing AJAX (XHR - 'XmlHttpRequest')
# xhr :HTTP_method, :action, controller: { hash of parameters }

# describe RatingsController do

#   let(:user) { FactoryGirl.create(:user) }
#   let(:post) { FactoryGirl.create(:post) }
#   let(:response) { FactoryGirl.create(:response) }

#   before { sign_in user, no_capybara: true }

#   describe "post rating with AJAX" do

#     describe "with invalid information" do

#       it "should not create a rating" do
#         expect do
#           post :create, format: "js"
#         end.not_to change(Rating, :count)
#       end

#       it "should respond with an error" do
#         xhr :post, :create, rating: { rateable_id: post.id, rateable_type: 'Post', value: ' ' }
#         expect(response).not_to be_success
#       end
#     end

#     describe "with valid information" do

#       it "should increment the Rating count" do
#         expect do
#           xhr :post, :create, :value => 2
#         end.to change(Rating, :count).by(1)
#       end

      # it "should respond with success message" do
      #   xhr :post, :create, post: { user: user, content: 'content' }
      #   expect(response).to be_success
      # end

      # it "should show the correct flash message" do
      #   xhr :post, :create, post: { user: user, content: 'content' }
      #   expect(flash[:success]).to eq "Post created!"
      # end
#     end
#   end
# end