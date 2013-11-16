require 'spec_helper'

### Response#Show ###

describe "Rating Creation" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post, user_id: user.id) }
  let!(:response) { FactoryGirl.create(:response, post_id: post.id) }
  before do
    sign_in user
    visit post_path(post)
  end
    
  describe "clicking 'weak'" do
    before { click_button 'weak' }
  
    it { should have_content("You rated this article: weak") }

    it "should update response author's score" do
      response.user.reload
      expect(response.user.score).to eq 1
    end
  end

  describe "clicking 'average'" do
    before { click_button 'average' }

    it { should have_content("You rated this article: average") }
  end

  describe "clicking 'thought provoking'" do
    before { click_button 'thought provoking' }

    it { should have_content("You rated this article: thought provoking") }

    it "does not send an email to admin" do
      Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
      expect(last_email.to).not_to include ('admin@thoughtsy.com')
    end
  end

  describe "clicking 'brilliant'" do
    before { click_button 'brilliant!' }

    it { should have_content("You rated this article: brilliant!") }

    it "saves a rating" do
      expect(Rating.where(value: 5).count).to eq 1
    end

    it "sends an email to admin" do
      Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
      expect(last_email.to).to include ('admin@thoughtsy.com')
    end

    describe "reloading the page" do
      before { visit post_path(post) }

      it "form is replaced by current rating" do
        page.has_no_xpath?("//form.new_rating")
        expect(page).to have_content("You rated this article: brilliant!")
      end
    end
  end

  # context "with AJAX", :js=>true do
  #   let(:response) { FactoryGirl.create(:response, post_id: post.id) }
  #   before { visit post_path(post) }

  #   describe "clicking 'weak'" do

  #     context "as post author" do
  #       before { click_button 'weak' }
      
  #       it "repost link appears and functions" do
  #         expect(page).to have_link("repost this thought")
  #         click_link("repost this thought")
  #         expect(page).to have_button("Post a thought")
  #         expect(page).to have_success_message("Thought reposted.")
  #       end
  #     end

  #     context "as post follower" do     ## not authorized to repost a thought ##
  #       let(:follower) { FactoryGirl.create(:user) }
  #       before do
  #         follower.subscribe!(post)
  #         sign_in follower
  #         visit post_path(post)
  #         click_button 'weak'
  #       end

  #       it "does not show repost link" do
  #         expect(page).not_to have_link("repost this thought")
  #         expect(page).to have_content("You rated this article: weak")
  #       end
  #     end
  #   end

  #   describe "clicking 'thought provoking'" do
  #     before { click_button 'thought provoking' }

  #     it { should have_link('Send a message') }
  #   end

  #   describe "clicking 'brilliant!'" do
  #     before { click_button 'brilliant!' }

  #     it "has links for message and sharing" do
  #       expect(page).to have_link('Send a message')
  #       expect(page).to have_selector('div#social_links')
  #     end
  #   end
  # end
end
