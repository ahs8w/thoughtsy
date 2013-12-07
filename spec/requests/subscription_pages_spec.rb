require 'spec_helper'

describe "Subscription" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post, created_at: 5.minutes.ago) }
  let!(:response) { FactoryGirl.create(:response, post_id: post.id, user_id: user.id) }
  before do
    sign_in user
    visit post_path(post)
  end

  describe "subscribing" do
    before { click_button "Repost" }

    it { should have_info_message("Thought followed.") }
    it { should have_content("You are following this post.") }
    it { should have_link("Unfollow") }

    it "updates follower attributes, post state, and user score" do
      post.reload
      expect(post.followers).to include user
      expect(post.state).to eq 'reposted'
      expect(post.user.score).to be 4     # (1 + 3)
    end

    describe "clicking unfollow (unsubscribing)" do
      before { click_link "Unfollow" }

      it { should have_info_message("Thought unfollowed.") }

      it "updates follower attribute and post state" do
        post.reload
        expect(post.followers).not_to include user
      end

      it "updates post author's score" do
        post.user.reload
        expect(post.user.score).to be 1
      end
    end
  end
end