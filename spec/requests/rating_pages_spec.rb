require 'spec_helper'

describe "Ratings" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post) }
  let!(:post2) { FactoryGirl.create(:post) }
  let(:response) { FactoryGirl.create(:response) }
  before do
    sign_in user
    visit root_path
  end

  # describe "Post form:" do
  #   before {click_button "Respond"}

  #   it "exists" do
  #     page.has_xpath?("//form.new_rating")
  #   end

  #   it "clicking a button saves a rating" do
  #     expect{click_button('average')}.to change(Rating, :count).by(1)
  #   end

  #   describe "returning after rating" do
  #     before do
  #       click_button('average')
  #       visit root_path
  #       click_button "Respond"
  #     end

  #     it "rating form does not appear" do
  #       page.has_no_xpath?("//form.new_rating")
  #       expect(page).to have_content("You rated this article: 2")
  #     end
  #   end
  # end

  # describe "Response form:" do
  #   before { visit response_path(response) }

  #   it "exists" do
  #     page.has_xpath?("//form.new_rating")
  #   end

  #   describe "without JS:" do
  #     it "clicking a button saves a rating" do
  #       expect{click_button('brilliant!')}.to change(Rating, :count).by(1)
  #     end

  #     describe "returning after rating" do
  #       before do
  #         click_button('brilliant!')
  #         visit root_path
  #         visit response_path(response)
  #       end

  #       it "rating form does not appear" do
  #         page.has_no_xpath?("//form.new_rating")
  #         expect(page).to have_content("You rated this article: 4")
  #       end
  #     end
  #   end
  # end

  # describe "with JS", :js => true do

  #   describe "rating a post" do
  #     before { click_button "Respond" }

  #     it "clicking a button displays current rating" do
  #       click_button('average')
  #       expect(page).to have_content("You rated this article: 2")
  #     end

  #     describe "clicking 'rubbish'" do
  #       before { click_button('rubbish') }
  #       it { should have_content("different thought") }

  #       describe "-> new post" do
  #         before { click_link("different thought") }
  #         it { should have_content(post2.content) }

  #         describe "properly persists" do
  #           before do
  #             visit root_path
  #             click_button "Respond"
  #           end

  #           it { should have_content(post2.content) }
  #         end
  #       end
  #     end
  #   end

  #   describe "rating a response" do
  #     before { visit response_path(response) }

  #     it "clicking a button displays current rating" do
  #       click_button('brilliant!')
  #       expect(page).to have_content("You rated this article: 4")
  #     end
  #   end
  # end
end
