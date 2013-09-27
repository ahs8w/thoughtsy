require 'spec_helper'

describe "Post pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "index page" do
    let(:admin) { FactoryGirl.create(:admin) }
    let!(:post) { FactoryGirl.create(:post, created_at: 1.minute.ago) }
    before do
      sign_in admin
      visit posts_path
    end

    it { should have_content("Queue") }
    it { should have_title("Queue") }
    it { should have_content(post.created_at) }
    it { should have_content(post.user.username) }
    it { should have_content(post.content) }
    it { should have_content(post.state) }

    describe "order of posts" do
      let!(:older_post) { FactoryGirl.create(:post, created_at: 5.minutes.ago) }

      it "should have the right post in the right order" do
        expect(first('tr')).to have_content(older_post.content)
      end
    end

    describe "should not included answered posts" do
      let(:answered_post) { FactoryGirl.create(:post, state: 'answered', content: 'foobar') }
      before { visit posts_path }

      it { should_not have_content(answered_post.content) }
    end

    describe "should include pending posts" do
      let!(:pending) { FactoryGirl.create(:pending) }

      it { should have_content(pending.content) }
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

## Setting post states ##    
  describe "response creation" do
    let!(:post) { FactoryGirl.create(:post) }
    before { visit root_path }

    it "should update the state of corresponding post to 'pending'" do
      expect(post).to be_unanswered
      click_button "Respond to a thought"
      post.reload
      expect(post).to be_pending
    end

    describe "with invalid information" do
      before { click_button "Respond to a thought" }

      it "should not change the post state" do
        click_button "Respond"
        post.reload
        expect(post).to be_pending
      end
    end

    describe "with valid information" do
      before do
        click_button "Respond to a thought"
        fill_in 'response_content', with: "Lorem Ipsum"
      end

      it "should update the state to 'answered'" do
        click_button "Respond"
        post.reload
        expect(post).to be_answered
      end
    end
  end
  
  describe "post creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a post" do
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
end
