require 'spec_helper'

# controller tests used for testing AJAX (XHR - 'XmlHttpRequest')
# xhr :HTTP_method, :action, controller: { hash of parameters }

describe PostsController do

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user, no_capybara: true }

  describe "post creation with AJAX" do

    describe "with invalid information" do

      it "should not create a post" do
        expect do
          xhr :post, :create, post: { user: user, content: ' ' }
        end.not_to change(Post, :count)
      end
    end

    describe "with valid information" do

      it "should increment the Post count" do
        expect do
          xhr :post, :create, post: { user: user, content: 'content' }
        end.to change(Post, :count).by(1)
      end

      it "should respond with success message" do
        xhr :post, :create, post: { user: user, content: 'content' }
        expect(response).to be_success
      end
    end
  end
end