require 'spec_helper'

describe "Post pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "index page" do
    before do
      FactoryGirl.create(:post)
      FactoryGirl.create(:post)
      visit posts_path
    end

    it { should have_title('Posts') }
    it { should have_content('Posts') }

    it "should list each post" do
      Post.all.each do |post|
        expect(page).to have_selector('li', text: post.content)
      end
    end

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:post) } }
      after(:all)  { Post.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each post" do
        Post.paginate(page: 1).each do |post|
          expect(page).to have_selector('li', text: post.content)
        end
      end
    end

    describe "delete links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit posts_path
        end

        it { should have_link('delete', href: post_path(Post.first)) }

        it "should be able to delete a post" do
          expect do
            click_link('delete', match: :first)
          end.to change(Post, :count).by(-1)
        end
      end
    end
  end

  describe "post creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a post" do
        expect { click_button "Post" }.not_to change(Post, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
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
  after(:all) { Topic.delete_all }
end
