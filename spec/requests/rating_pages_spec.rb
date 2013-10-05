require 'spec_helper'

describe "Ratings" do
  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post) }
  before do
    sign_in user
    visit root_path
  end

  describe "Post#Show form" do
    before {click_button "Respond"}

    it "exists" do
      expect(page).to have_selector("div#rating_form")
      expect(page).to have_content("brilliant!")
    end

    describe "without JS: clicking submit" do
      before { choose('rating_value_2') }
      
      it "saves rating" do
        # click_button('Submit')
        # expect(page).to have_content("Rating saved.")        
        expect{click_button('Submit')}.to change(Rating, :count).by(1)
      end

      describe "returning after rating" do
        before do
          click_button('Submit')
          visit root_path
          click_button "Respond"
        end

        it "rating form does not appear" do
          expect(page).not_to have_selector("div#rating_form")
          expect(page).to have_content("You rated this article:")
        end
      end
    end
  end

  describe "Response#Show form" do
    let(:response) { FactoryGirl.create(:response) }
    before { visit response_path(response) }

    it "exists" do
      expect(page).to have_selector("div#rating_form")
      expect(page).to have_content("brilliant!")
    end

    describe "without JS: clicking submit" do
      before { choose('rating_value_2') }
      
      it "saves rating" do
        # click_button('Submit')
        # expect(page).to have_content("Rating saved.")        
        expect{click_button('Submit')}.to change(Rating, :count).by(1)
      end

      describe "returning after rating" do
        before do
          click_button('Submit')
          visit root_path
          visit response_path(response)
        end

        it "rating form does not appear" do
          expect(page).not_to have_selector("div#rating_form")
          expect(page).to have_content("You rated this article:")
        end
      end
    end
  end
end
