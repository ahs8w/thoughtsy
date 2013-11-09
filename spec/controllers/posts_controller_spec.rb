require 'spec_helper'

# controller tests used for testing AJAX (XHR - 'XmlHttpRequest')
# xhr :HTTP_method, :action, controller: { hash of parameters }
# testing controller methods

describe PostsController do

  let(:user) { FactoryGirl.create(:user) }   # :admin - for testing destruction as well
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

      it "should show the correct flash message" do
        xhr :post, :create, post: { user: user, content: 'content' }
        expect(flash[:success]).to eq "Post created!"
      end
    end
  end

  # describe "post destruction with AJAX" do
  #   let!(:post) { FactoryGirl.create(:post, user: user, content: 'whatever') }

  #   it "should respond with success" do
  #     xhr :delete, :destroy, id: post.id
  #     expect(response).to be_success
  #   end

  #   it "should decrement the post count" do
  #     expect do
  #       xhr :delete, :destroy, { id: post.id }
  #     end.to change(Post, :count).by(-1)
  #   end

  #   it "should show correct flash message" do
  #     xhr :delete, :destroy, id: post.id
  #     expect(flash[:success]).to eq "Post destroyed!"
  #   end
  # end

  describe "flag a post" do
    let!(:post) { FactoryGirl.create(:post) }
    before { user.set_tokens(post.id) }

    it "shows flash and changes post state" do
      get :flag, id: post.id
      expect(flash[:notice]).to eq "Post flagged."
      post.reload
      expect(post.state).to eq 'flagged'
    end
  end

  describe "repost" do
    let!(:post) { FactoryGirl.create(:post, user_id: user.id) }

    it "unanswers post and flashes success" do
      xhr :get, :repost, id: post.id
      expect(flash[:success]).to eq "Thought reposted."
      post.reload
      expect(post.state).to eq 'reposted'
    end
  end
end