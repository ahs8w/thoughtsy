require 'spec_helper'

describe "Post pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "queue page" do
    let(:admin) { FactoryGirl.create(:admin) }
    let!(:post) { FactoryGirl.create(:post, created_at: 1.minute.ago) }
    before do
      sign_in admin
      visit queue_path
    end

    it { should have_content("Queue") }
    it { should have_title("Queue") }
    it { should have_content(post.created_at) }
    it { should have_content(post.user.username) }
    it { should have_content(post.content) }
    it { should have_content(post.state) }

    describe "order of posts" do
      let!(:older_post) { FactoryGirl.create(:post, created_at: 5.minutes.ago) }
      before { visit queue_path }

      it "should have the right post in the right order" do
        expect(first('tr')).to have_content(older_post.content)
      end
    end

    describe "should not included answered posts" do
      let(:answered_post) { FactoryGirl.create(:post, state: 'answered', content: 'foobar') }
      before { visit queue_path }

      it { should_not have_content(answered_post.content) }
    end

    describe "should include pending posts" do
      let!(:pending) { FactoryGirl.create(:post, state: 'pending') }
      before { visit queue_path }

      it { should have_content(pending.content) }
    end

    describe "should include flagged posts" do
      let!(:flagged) { FactoryGirl.create(:post, state: 'flagged') }
      before { visit queue_path }

      it { should have_content(flagged.content) }
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
  end

  describe "show page" do
    let!(:post) { FactoryGirl.create(:post) }
    before do
      visit root_path
      click_button "Respond"
    end

    it { should have_title("Respond") }
    it { should have_content(post.user.username) }
    it { should have_content(post.content) }
    it { should have_field('response_content') }
    it { should have_button("Respond") }

    it "sets tokens for user" do
      expect(user.token_timer).to be_blank
      user.reload
      expect(user.token_id).to eq post.id
      expect(user.token_timer).to be_present
    end
  end

  describe "Persistance:" do
    let!(:post) { FactoryGirl.create(:post, created_at: 1.minute.ago) }
    before do
      visit root_path
      click_button "Respond"
    end

    describe "with an earlier post in existence" do
      let!(:older_post) { FactoryGirl.create(:post, content: "blah", created_at: 5.minutes.ago) }

      it "the same post persists upon returning to page" do
        visit root_path
        click_button "Respond"
        expect(page).to have_content(post.content)
      end
    end

    describe "after 24 hours" do
      let!(:newer_post) { FactoryGirl.create(:post, content: "blah") } #need a post to have 'Respond' button
      before do
        user.token_timer = 25.hours.ago
        user.save
        visit root_path
        click_button "Respond"
      end

      it "the same post does not persist" do
        expect(page).to have_content(newer_post.content)
      end

      # describe "with only younger posts in existence" do
      #   before do
      #     post.created_at = 2.days.ago
      #     post.save
      #     visit root_path
      #   end

      #   it "the user should not have same token_id" do
      #     click_button "Respond"
      #     user.reload
      #     expect(user.token_id).not_to eq post.id
      #   end
      # end
    end
  end

  describe "[post states]" do
    let!(:post) { FactoryGirl.create(:post) }
    before { visit root_path }

    it "updates the state to 'pending'" do
      expect(post).to be_unanswered
      click_button "Respond"
      post.reload
      expect(post).to be_pending
    end

    describe "response creation" do
      before { click_button "Respond" }

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
      end
    end
  end
 
  describe "post creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "does not create a post" do
        expect { click_button "Post a thought" }.not_to change(Post, :count)
      end

      describe "error messages" do
        before { click_button "Post a thought" }
        it { should have_error_message('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'post_content', with: "Lorem ipsum" }
      it "should create a post" do
        expect { click_button "Post" }.to change(Post, :count).by(1)
      end
    end
  end

  ## actions from Response#Show page ##
  describe "reposting" do
    let!(:answered_post) { FactoryGirl.create(:post, user_id: user.id, state: 'answered') }
    
    it "changes state and displays flash" do
      visit repost_post_path(answered_post)
      answered_post.reload
      expect(answered_post.state).to eq 'unanswered'
      expect(page).to have_success_message("Thought reposted.")
    end
  end

  ## actions from Post#Show page ##
  describe "flagging and reposting" do
    let(:post) { FactoryGirl.create(:post) }
    before { visit post_path(post) }

    it { should have_link("offensive or inappropriate?") }
    it { should have_link("repost and follow") }

    describe "clicking offensive" do
      let!(:post2) { FactoryGirl.create(:post) }
      before { click_link "offensive" }

      it { should have_content(post2.content) }
      it { should have_content("Post flagged.") }

      it "sends an email to admin" do
        expect(last_email.to).to include('admin@thoughtsy.com')
      end
    end

    describe "clicking repost" do
      before { click_link "repost" }

      it { should have_success_message("Thought followed.") }

      it "updates follower attribute" do
        post.reload
        expect(post.followers).to include user
      end
    end

    describe "after subscribing and returning to the page" do
      before do
        user.subscribe!(post)
        visit post_path(post)
      end

      it { should have_content("You are following this post.") }
      it { should_not have_link("repost") }
    end
  end
end
