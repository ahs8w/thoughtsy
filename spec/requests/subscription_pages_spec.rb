require 'spec_helper'

describe "Subscription" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post) }
  before { sign_in user }

  ## actions from Post#Show page ##
  describe "Post#Show page" do
    before { visit post_path(post) }

    it "post state is 'pending'" do
      post.reload
      expect(post.state).to eq 'pending'
    end

    describe "clicking follow" do 
      before { click_button "follow" }

      it { should have_success_message("Thought followed.") }

      it "updates follower attributes and post state" do
        post.reload
        expect(post.followers).to include user
        expect(post.state).to eq 'unanswered'
      end
  
      describe "after subscribing and returning to the page" do
        before { visit post_path(post) }

        it { should have_content("You are following this post.") }
        it { should have_link("unfollow") }

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
end