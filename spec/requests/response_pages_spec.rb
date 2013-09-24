require 'spec_helper'

describe "ResponsePages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post) }
  before { sign_in user }

  describe "index page" do
    let!(:response) { FactoryGirl.create(:response) }
    before { visit responses_path }

    it { should have_title('Responses') }
    it { should have_content('Responses') }
    it { should have_content(response.content) }
    it { should have_content(response.user.username) }
    it { should have_content(response.post.user.username) }
    it { should have_content(response.post.content) }

    describe "pagination" do
      before(:all) { 31.times { FactoryGirl.create(:response) } }
      after(:all)  { Post.delete_all }
      after(:all)  { Response.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each post" do
        Response.paginate(page: 1).each do |response|
          expect(page).to have_selector('li', text: response.content)
        end
      end
    end  
  end

  describe "response creation" do
    before { visit root_path }

    describe "with invalid information" do
      before { click_button "Respond to a thought" }

      it "should not create a response" do
        expect { click_button "Respond" }.not_to change(Response, :count)
      end

      it "should have an error message" do
        click_button "Respond"
        expect(page).to have_error_message("error")
      end
    end

    describe "with valid information" do
      before do
        click_button "Respond to a thought"
        fill_in 'response_content', with: "Lorem Ipsum"
      end

      it "should create a response" do
        expect { click_button "Respond" }.to change(Response, :count).by(1)
      end
    end
  end

  describe "delete links" do
    let!(:response) { FactoryGirl.create(:response) }
    let(:admin) { FactoryGirl.create(:admin) }

    it { should_not have_link('delete') }

    describe "as admin should have delete links" do
      before do
        sign_in admin
        visit responses_path
      end

      it { should have_link('delete', href: response_path(response)) }

      it "should delete response" do
        expect do
          click_link('delete', match: :first)
        end.to change(Response, :count).by(-1)

        expect(page).to have_success_message('Response destroyed!')
      end
    end
  end

  #   describe "as an admin user" do
  #     let(:admin) { FactoryGirl.create(:admin) }
  #     before do
  #       sign_in admin
  #       visit posts_path
  #     end

  #     it { should have_link('delete', href: post_path(Post.first)) }

  #     it "should be able to delete a post" do
  #       expect do
  #         click_link('delete', match: :first)
  #       end.to change(Post, :count).by(-1)
  #     end
  #   end
  # end
end
