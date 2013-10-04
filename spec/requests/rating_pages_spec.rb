require 'spec_helper'

describe "Ratings" do
  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post) }
  before do
    sign_in user
    visit root_path
  end

  describe "show page form" do
    before {click_button "Respond"}

    it "exists" do
      expect(page).to have_selector("div#rating_form")
      expect(page).to have_content("brilliant!")
    end

    describe "no JS: clicking submit" do
      
      it "saves rating" do
        choose('rating_value_2')
        
        expect{click_on('Submit')}.to change(Rating, :count).by(1)
      end

      describe "returning after rating" do
        before do
          visit root_path
          click_button "Respond"
        end

        it "does not save again" do
          choose('rating_value_4')
          expect{click_on('Submit')}.not_to change(Rating, :count)
        end
      end
    end
  end
end
