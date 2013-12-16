require 'spec_helper'

describe "Image Pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post) }
  before do
    sign_in user
    visit root_path
  end

  describe "Post.image:" do
    before do
      click_link "Post"
      click_link "Upload"
    end

    it { should have_title "Image Upload" }

    # it "displays file upload modal", js:true do
    #   expect(page).to have_selector "modal"
    # end

    # describe "with an invalid filetype" do

    #   it "raises an error" do
    #     attach_file_for_direct_upload("#{Rails.root}/spec/support/fake.svg")
    #     upload_directly(ImageUploader.new, "Upload")
    #     expect{ click_button "Post" }.not_to change(Post, :count)
    #     expect(page).to have_error_message
    #   end
    # end

    # describe "with a valid filetype" do
    #   before { attach_file_for_direct_upload("#{Rails.root}/spec/support/test.png") }

    #   it "saves post" do
    #     expect{ click_button "Post" }.to change(Post, :count).by(1)
    #     expect(page).to have_success_message("Post created!")
    #   end
    # end
  end

  describe "Response.image" do
    before do
      click_link "Respond"
      click_link "Upload"
    end

    it { should have_title "Image Upload" }
  end
end