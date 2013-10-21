require 'spec_helper'

describe "Subscription" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post) }
  before do
    sign_in user
    visit root_path
  end

  describe "Response#New page" do
    before { click_button "Respond" }

    it "post state is 'pending'" do
      post.reload
      expect(post.state).to eq 'pending'
    end

    describe "clicking follow" do 
      before { click_button "follow" }

      it { should have_success_message("Thought followed.") }
      it { should have_content("You are following this post.") }
      it { should have_link("unfollow") }

      it "updates follower attributes and post state" do
        post.reload
        expect(post.followers).to include user
        expect(post.state).to eq 'unanswered'
      end
  
      describe "clicking unfollow (unsubscribing)" do
        before { click_link "unfollow" }

        it { should have_success_message("Thought unfollowed.") }

        it "updates follower attribute and post state" do
          post.reload
          expect(post.followers).not_to include user
          expect(post.state).to eq 'pending'
        end
      end
    end
  end
end