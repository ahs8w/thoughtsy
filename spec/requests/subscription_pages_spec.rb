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

    describe "following (clicking repost)" do
      before { click_button "repost" }

      it { should have_info_message("Thought followed.") }
      it { should have_content("You are following this post.") }
      it { should have_link("unfollow") }

      it "updates follower attributes, post state, and user score" do
        post.reload
        expect(post.followers).to include user
        expect(post.state).to eq 'subscribed'
        expect(post.user.score).to be 4     # (1 + 3)
      end

      describe "after answering followed post" do
        let!(:newer_post) { FactoryGirl.create(:post, created_at: 2.minutes.ago) }
        before do
          fill_in 'response_content', with: "Lorem Ipsum"
          click_button "Respond"
        end

        it "click respond again does not yield the same post" do
          visit root_path
          click_button "Respond"
          expect(page).not_to have_content("#{post.content}")
        end

        describe "as a different user" do
          let(:new_user) { FactoryGirl.create(:user) }
          before { sign_in new_user }

          it "clicking respond does not yield the answered post" do
            visit root_path
            click_button "Respond"
            expect(page).not_to have_content("#{post.content}")
          end
        end
      end

      describe "clicking unfollow (unsubscribing)" do
        before { click_link "unfollow" }

        it { should have_info_message("Thought unfollowed.") }

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