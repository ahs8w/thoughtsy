require 'spec_helper'

describe "Ratings" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:response) { FactoryGirl.create(:response) }
  before do
    sign_in user
    visit response_path(response)
  end

  describe "Creation:" do

    it "form:" do
      page.has_xpath?("//form.new_rating")
    end

    it "clicking a button saves a rating" do
      expect{click_button 'brilliant!' }.to change(Rating, :count).by(1)
    end

    describe "returning after rating" do
      before do
        click_button 'brilliant!'
        visit root_path
        visit response_path(response)
      end

      it "form is replaced by current rating" do
        page.has_no_xpath?("//form.new_rating")
        expect(page).to have_content("You rated this article: brilliant!")
      end
    end
  end

  # describe "Creation with JS:", :js => true do

  #   describe "clicking 'weak'" do
  #     before { click_button 'weak' }
    
  #     it { should have_link("repost this thought") }
  #     it { should have_content("You rated this article: weak") }

  #     describe "-> repost" do
  #       before { click_link("repost this thought") }
  #       it { should have_success_message("Thought reposted.") }
  #       it { should have_button("Post a thought") }
  #     end
  #   end

  #   describe "clicking 'brilliant!'" do
  #     before { click_button 'brilliant!' }

  #     it { should have_link("send a note") }
  #     it { should have_content("You rated this article: thought provoking") }

  #     describe "-> send a note" do
  #       before { click_link("send a note") }
  #       it { should have_content("Note to #{response.user.username}") }
  #     end
  #   end
  # end
end
