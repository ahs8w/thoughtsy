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
    it { should have_content(post.responded_to) }

    describe "order of posts" do
      let!(:older_post) { FactoryGirl.create(:post, created_at: 5.minutes.ago) }

      it "should have the right post in the right order" do
        expect(first('tr')).to have_content(older_post.content)
      end
    end

    describe "should not included posts with responses" do
      before do
        visit root_path
        click_link "Respond"
        fill_in "response_content", with: "response"
        click_on "Respond"
        visit posts_path
      end

      it { should_not have_content(post.content) }
    end

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:post) } }
      after(:all)  { Post.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each post" do
        Post.paginate(page: 1).each do |post|
          expect(page).to have_selector('td', text: post.content)
        end
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
