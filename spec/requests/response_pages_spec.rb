require 'spec_helper'

describe "ResponsePages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "index page" do
    before { visit responses_path }

    it { should have_title('Responses') }
    it { should have_content('Responses') }

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

  # before do
  #   sign_in user
  #   FactoryGirl.create(:post)
  # end

  # describe "response creation" do
  #   before { visit posts_path }

  #   describe "with invalid information" do
  #     before { click_link "Respond" }

  #     it "should not create a response" do
  #       expect { click_button "Respond" }.not_to change(Response, :count)
  #     end

  #     describe "error messages" do
  #       before { click_button "Respond" }
  #       it { should have_error_message('error') }
  #     end
  #   end

  #   describe "with valid information" do
  #     before do
  #       click_link "Respond"
  #       fill_in 'response_content', with: "Lorem Ipsum"
  #     end

  #     it "should create a response" do
  #       expect { click_button "Respond" }.to change(Response, :count).by(1)
  #     end
  #   end
  # end

  # describe "delete links" do

  #   it { should_not have_link('delete') }

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
