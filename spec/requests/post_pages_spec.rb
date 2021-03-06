require 'spec_helper'

describe "Post pages" do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  subject { page }

  describe "Queue page" do
    let(:admin) { FactoryGirl.create(:admin) }
    let!(:post) { FactoryGirl.create(:post) }
    before do
      sign_in admin
      visit queue_path
    end

    it { should have_content("Queue") }
    it { should have_title("Queue") }
    it { should have_content(post.sort_date) }
    it { should have_content(post.user.username) }
    it { should have_content(post.content) }
    it { should have_content(post.responses.size) }
    it { should_not have_content("[image]") }
    it { should have_content(post.state) }

    describe "order of posts" do
      let!(:post2) { FactoryGirl.create(:post) }
      before do
        post2.update_column(:sort_date, 5.minutes.ago)
        visit queue_path
      end

      it "older post(by sort_date) is first" do
        expect(first('tr')).to have_content(post2.content)
      end

      describe "after answered" do
        before do
          post2.answer!
          visit queue_path
        end

        it "sort_date is changed" do
          expect(first('tr')).to have_content(post.content)
        end
      end

      describe "after accepted and expired" do
        before do
          post2.accept!
          post2.expire!
          visit queue_path
        end

        it "sort_date is unchanged" do
          expect(first('tr')).to have_content(post2.content)
        end
      end
    end

    describe "does not include unqueued posts" do
      let(:unqueued_post) { FactoryGirl.create(:post, state: 'unqueued') }
      before { visit queue_path }

      it { should_not have_content(unqueued_post.content) }
    end

    describe "includes pending posts" do
      let!(:pending) { FactoryGirl.create(:post, state: 'pending') }
      before { visit queue_path }

      it { should have_content(pending.content) }
    end

    describe "includes flagged posts" do
      let!(:flagged) { FactoryGirl.create(:post, state: 'flagged') }
      before { visit queue_path }

      it { should have_content(flagged.content) }
    end

    describe "includes answered posts" do
      let!(:answered) { FactoryGirl.create(:post, state: 'answered') }
      before { visit queue_path }

      it { should have_content(answered.content) }
    end

    # describe "pagination" do
    #   before(:all) { 30.times { FactoryGirl.create(:post) } }
    #   after(:all)  { Post.delete_all }

    #   it { should have_selector('div.pagination') }

    #   it "should list each post" do
    #     Post.paginate(page: 1).each do |post|
    #       expect(page).to have_selector('td', text: post.content)
    #     end
    #   end
    # end

    describe "delete links" do
      
      context "without flagged posts" do
        it { should_not have_link('delete') }
      end

      context "with flagged posts" do
        let!(:flagged) { FactoryGirl.create(:post, state: 'flagged') }
        before { visit queue_path }

        it { should have_link('delete', href: post_path(flagged)) }

        describe "clicking delete" do

          it "deletes post and flashes success" do
            expect do
              click_link('delete', match: :first)
            end.to change(Post, :count).by(-1)

            expect(page).to have_success_message('Post destroyed!')
          end
        end
      end
    end
  end

  describe "Index page" do
    include ActionView::Helpers::DateHelper
    
    let!(:post) { FactoryGirl.create(:post, state: 'answered') }
    let!(:response) { FactoryGirl.create(:response, post_id: post.id) }

    before { visit posts_path }

    it { should have_title("Thoughts") }
    it { should have_link(post.content) }
    it { should have_content(time_ago_in_words(response.created_at)) }

    describe "order of posts" do
      let!(:post2) { FactoryGirl.create(:post, state: 'answered') }
      before do
        post2.update_column(:sort_date, 5.minutes.ago)
        visit posts_path
      end

      it "newer post(by sort_date) is first" do
        expect(first('h3')).to have_content(post.content)
      end

      context "after reanswered" do
        before do
          post2.answer!
          visit posts_path
        end

        it "sort_date is changed" do
          expect(first('h3')).to have_content(post2.content)
        end
      end

      context "after reaccepted and expired" do
        before do
          #repost_and_expire -> changes state from pending back to reposted
          post2.accept!
          post2.expire!
          visit posts_path
        end

        it "sort_date is unchanged" do
          expect(first('h3')).to have_content(post.content)
        end
      end
    end

    describe "includes only .answered posts" do
      let(:unanswered) { FactoryGirl.create(:post, state: 'unanswered') }
      let!(:pending) { FactoryGirl.create(:post, state: 'pending') }
      let!(:flagged) { FactoryGirl.create(:post, state: 'flagged') }
      let!(:answered) { FactoryGirl.create(:post, state: 'answered') }
      before { visit posts_path }

      it { should_not have_content(unanswered.content) }
      it { should_not have_content(pending.content) }
      it { should_not have_content(flagged.content) }
      it { should have_content(answered.content) }
    end
  end

  describe "Show page" do
    let!(:post) { FactoryGirl.create(:post, user_id: user.id) }
    let!(:response) { FactoryGirl.create(:response, post: post) }
    before { visit post_path(post) }

    it { should have_title("Responses") }
    it { should have_content(post.user.username) }
    it { should have_content(post.content) }
    it { should have_content(response.content) }
    it { should have_content(response.user.username) }
    
    describe "response order" do
      let!(:older_response) { FactoryGirl.create(:response, post: post, created_at: 5.minutes.ago) }
      before { visit post_path(post) }
      
      it "newer response is first" do
        expect(first('ul.responses li')).to have_content(response.content)
      end
    end

    describe "with post image" do
      let!(:image_post) { FactoryGirl.create(:image_post) }
      before { visit post_path(image_post) }

      it { should have_selector('img') }
    end

    describe "response ratings" do

      context "as post author" do
        it { should have_selector("div.rating_form") }
      end

      context "as guest" do
        let(:guest) { FactoryGirl.create(:user) }

        before do
          sign_in guest
          visit post_path(post)
        end

        it { should_not have_selector("div.rating_form") }
      end

      context "as response author" do
        before do
          sign_in response.user
          visit post_path(post)
        end

        it { should_not have_selector("div.rating_form") }
      end

      context "as another responder" do
        let(:another_response) { FactoryGirl.create(:response, post_id: post.id) }
        before do
          sign_in another_response.user
          visit post_path(post)
        end

        it { should have_selector('div.rating_form') }
      end
    end
  end

  describe "New page" do
    before do
      visit root_path
      click_link "Post"
    end

    it { should have_selector('#thought_form') }

    describe "Post Creation" do

      context "with invalid information" do
        before { click_button "Post" }

        it "does not create a post" do
          expect(Post.count).not_to eq 1
        end

        it "should have error message" do
          expect(page).to have_selector('#error_explanation')
        end
      end

      context "with valid information" do

        before { fill_in 'post_content', with: "Lorem ipsum" }
        it "should create a post" do
          expect { click_button "Post" }.to change(Post, :count).by(1)
        end
      end
    end
  end

## Response#New ##
  describe "Response Page actions" do
    let!(:post) { FactoryGirl.create(:post) }
    before do
      visit root_path
      click_link "Respond"
    end

    describe "Flag action" do

      context "with no other available posts" do
        before { click_link "inappropriate post?" }

        it "displays flash and redirects to home page" do
          expect(page).to have_content "Thought flagged."
          expect(page).to have_link "Post!"
        end

        it "resets post state and user tokens" do
          post.reload
          expect(post).to be_flagged
          user.reload
          expect(user.token_id).to be nil
        end

        it "sends an email to admin" do
          Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
          expect(last_email.to).to include('a.h.schiller@gmail.com')
        end
      end

      context "with available post" do
        let!(:token_post) { FactoryGirl.create(:post) }
        before { click_link "inappropriate post?" }

        it "gets a new post and sets states" do
          expect(page).to have_content(token_post.content)
          user.reload
          expect(user.token_id).to eq token_post.id
        end
      end
    end

    describe "Language action" do

      context "with no available posts" do
        before { click_link "not your language?" }

        it "displays flash and redirects to home page" do
          expect(page).to have_content "Thought reposted."
          expect(page).to have_link "Post!"
          expect(page).to have_content "currently no unanswered posts"
        end

        it "resets post state and user tokens (not score)" do
          post.reload
          expect(post).to be_unanswered
          expect(post.token_timer).to be nil
          user.reload
          expect(user.token_id).to be nil
          expect(user.score).to eq 0
        end
      end

      context "with available post" do
        let!(:token_post) { FactoryGirl.create(:post) }
        before { click_link "not your language?" }

        it "gets a new post and sets states" do
          expect(page).to have_content(token_post.content)
          user.reload
          expect(user.token_id).to eq token_post.id
        end
      end

      context "with existing responses" do
        let!(:response) { FactoryGirl.create(:response, post_id: post.id) }
        before { click_link "not your language" }

        it "returns post state to 'answered'" do
          post.reload
          expect(post).to be_answered
        end
      end
    end
  end

  describe "Post States:" do
    let!(:post) { FactoryGirl.create(:post) }
    before { visit root_path }

    it "updates the state to 'pending'" do
      expect(post).to be_unanswered
      click_link "Respond"
      post.reload
      expect(post).to be_pending
    end

    describe "response creation" do
      before { click_link "Respond" }

      context "with invalid information" do

        it "does not change the state" do
          click_button "Respond"
          post.reload
          expect(post).to be_pending
        end
      end

      context "with valid information" do
        before { fill_in 'response_content', with: "Lorem Ipsum" }

        it "updates the state to 'answered'" do
          click_button "Respond"
          post.reload
          expect(post).to be_answered
        end

        describe "as the third response (without ratings)" do
          let!(:response1) { FactoryGirl.create(:response, post_id: post.id) }
          let!(:response2) { FactoryGirl.create(:response, post_id: post.id) }

          it "updates the state to 'unqueued'" do
            click_button "Respond"
            post.reload
            expect(post).to be_unqueued
          end
        end
      end
    end
  end
end
