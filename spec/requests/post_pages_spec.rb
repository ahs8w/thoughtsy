require 'spec_helper'

describe "Post pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "Queue page" do
    let(:admin) { FactoryGirl.create(:admin) }
    let!(:post) { FactoryGirl.create(:post, updated_at: 1.minute.ago) }
    before do
      sign_in admin
      visit queue_path
    end

    it { should have_content("Queue") }
    it { should have_title("Queue") }
    it { should have_content(post.updated_at) }
    it { should have_content(post.user.username) }
    it { should have_content(post.content) }
    it { should have_content(post.state) }

    describe "order of posts" do
      let!(:older_post) { FactoryGirl.create(:post, updated_at: 5.minutes.ago) }
      before { visit queue_path }

      it "oldest post is first" do
        expect(first('tr')).to have_content(older_post.content)
      end
    end

    describe "does not include answered posts" do
      let(:answered_post) { FactoryGirl.create(:post, state: 'answered', content: 'foobar') }
      before { visit queue_path }

      it { should_not have_content(answered_post.content) }
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
    let(:user) { FactoryGirl.create(:user) }
    let!(:post) { FactoryGirl.create(:post, updated_at: 1.hour.ago, state: 'answered') }
    before do
      sign_in user
      visit posts_path
    end

    it { should have_title("Thoughts") }
    # it { should have_content(post.user.username) }
    it { should have_content(post.content) }

    describe "order of posts" do
      let!(:newer_post) { FactoryGirl.create(:post, updated_at: 5.minutes.ago, state: 'answered') }
      before { visit posts_path }

      it "newest post is first" do
        expect(first('.index_post')).to have_content(newer_post.content)
      end
    end

    describe "includes only answered posts" do
      let(:unanswered) { FactoryGirl.create(:post, state: 'unanswered') }
      let!(:pending) { FactoryGirl.create(:post, state: 'pending') }
      let!(:flagged) { FactoryGirl.create(:post, state: 'flagged') }
      before { visit posts_path }

      it { should_not have_content(unanswered.content) }
      it { should_not have_content(pending.content) }
      it { should_not have_content(flagged.content) }
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
    it { should_not have_link('delete') }
    
    describe "response order" do
      let!(:older_response) { FactoryGirl.create(:response, post: post, created_at: 5.minutes.ago) }
      before { visit post_path(post) }
      
      it "newer response is first" do
        expect(first('.responses_show li')).to have_content(response.content)
      end
    end

    describe "with post image" do
      let!(:image_post) { FactoryGirl.create(:image_post) }
      before { visit post_path(image_post) }

      it { should have_selector('img') }
    end

    describe "rating form access" do

      context "as post author" do
        it { should have_selector("div.rating_form") }
      end

      context "as post follower" do
        let(:follower) { FactoryGirl.create(:user) }
        before do
          sign_in follower
          follower.subscribe!(post)
          visit post_path(post)
        end

        it { should have_selector("div.rating_form") }

        context "as guest" do
          before do
            follower.unsubscribe!(post)
            visit post_path(post)
          end

          it { should_not have_selector("div.rating_form") }
        end
      end

      context "as response author" do
        before do
          sign_in response.user
          response.user.subscribe!(post)
          visit post_path(post)
        end

        it { should_not have_selector("div.rating_form") }
      end
    end
  end

## Response#New ##
  describe "Flag action" do
    let!(:post) { FactoryGirl.create(:post) }
    let!(:token_post) { FactoryGirl.create(:post) }
    before do
      visit root_path
      click_button "Respond"
      click_link "offensive or inappropriate?"
    end

    it "displays flash, and changes post state" do
      expect(page).to have_content "Post flagged."
      post.reload
      expect(post).to be_flagged
    end

    it "gets a new post and sets states" do
      expect(page).to have_content(token_post.content)
      user.reload
      expect(user.token_id).to eq token_post.id
    end

    it "sends an email to admin" do
      Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
      expect(last_email.to).to include('admin@thoughtsy.com')
    end
  end

  describe "Repost action" do
    # covered in ratings_pages_spec -> accessed through AJAX ratings form
    # action covered in posts_controller_spec
  end

## StaticPages#Home ##

  ## 'Respond_button' ##
  describe "Persistance:" do
    let!(:post) { FactoryGirl.create(:post, updated_at: 1.minute.ago) }
    before do
      visit root_path
      click_button "Respond"
    end

    describe "with an earlier post in existence" do
      let!(:older_post) { FactoryGirl.create(:post, content: "blah", updated_at: 5.minutes.ago) }

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
      #     post.updated_at = 2.days.ago
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

  ## Response creation ##
  describe "States:" do
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
 
  ## 'Post_a_thought' ##
  describe "Post#Create" do
    before { visit root_path }

    context "with invalid information" do

      it "does not create a post" do
        expect { click_button "Post a thought" }.not_to change(Post, :count)
      end

      describe "error messages" do
        before { click_button "Post a thought" }
        it { should have_error_message('error') }
      end
    end

    context "with valid information" do

      before { fill_in 'post_content', with: "Lorem ipsum" }
      it "should create a post" do
        expect { click_button "Post" }.to change(Post, :count).by(1)
      end
    end

    context "as an image" do

      context "through direct file upload link" do
        before { attach_file('post[image]', "#{Rails.root}/spec/support/test.png") }

        it "saves post" do
          expect{ click_button "Post" }.to change(Post, :count).by(1)
          expect(page).to have_success_message("Post created!")
        end
      end

      context "through image url field" do
        before { fill_in 'post[remote_image_url]', with: 'http://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Marmaraytwotunnel.JPG/800px-Marmaraytwotunnel.JPG' }

        it "saves post" do
          expect { click_button "Post" }.to change(Post, :count).by(1)
        end
      end
    end
  end
end
