require 'spec_helper'

describe "Subscription" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post, created_at: 5.minutes.ago) }
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

      it "updates follower attributes, post state, and user score" do
        post.reload
        expect(post.followers).to include user
        expect(post.state).to eq 'subscribed'
        expect(post.user.score).to be 4
      end

      describe "answering followed post and clicking respond again" do
        let!(:newer_post) { FactoryGirl.create(:post, created_at: 2.minutes.ago) }
        before do
          fill_in 'response_content', with: "Lorem Ipsum"
          click_button "Respond"
          visit root_path
          click_button "Respond"
        end

        it "the same post does not appear again" do
          expect(page).not_to have_content("#{post.content}")
        end
      end

      describe "clicking unfollow (unsubscribing)" do
        before { click_link "unfollow" }

        it { should have_success_message("Thought unfollowed.") }

        it "updates follower attribute and post state" do
          post.reload
          expect(post.followers).not_to include user
          expect(post.state).to eq 'pending'
        end

        it "updates post author's score" do
          post.user.reload
          expect(post.user.score).to be 1
        end
      end
    end
  end
end