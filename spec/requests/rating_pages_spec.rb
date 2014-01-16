require 'spec_helper'

### Response#Show ###

describe "Rating" do
  subject { page }

  context "a Response" do

    let!(:response) { FactoryGirl.create(:response, id: 5) }
    before do
      sign_in response.post.user  #post author
      visit post_path(response.post)
    end

    it { should have_selector('form#new_rating', :count => 4) }

    describe "clicking 'weak'" do
      before { click_button 'weak' }
    
      it { should have_content("You rated this thought: weak") }

      it "should update response author's score" do
        # response.user.reload
        expect(response.user(true).score).to eq 1
      end
    end

    describe "clicking 'average'" do
      before { click_button 'average' }

      it { should have_content("You rated this thought: average") }
    end

    describe "clicking 'thought provoking'" do
      before { click_button 'thought provoking' }

      it { should have_content("You rated this thought: thought provoking") }
    end

    describe "clicking 'brilliant'" do
      before { click_button 'brilliant!' }

      it { should have_content("You rated this thought: brilliant!") }

      it "saves a rating" do
        expect(Rating.where(value: 5).count).to eq 1
      end

      it "sends an email to admin" do
        Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
        expect(last_email.to).to include ('a.h.schiller@gmail.com')
      end

      describe "reloading the page" do
        before { visit post_path(response.post) }

        it "form is replaced by current user rating" do
          page.has_no_selector?("form#new_rating")
          expect(page).to have_content("You rated this thought: brilliant!")
        end

        ## RatingsHelper - current_user_rating ##
        context "with another rating sharing the same rateable_id" do
          let(:post) { FactoryGirl.create(:post, id: 5) }
          let(:rating) { post.ratings.new(user_id: response.post.user.id, value: 1) }
          before do
            rating.save
            visit post_path(response.post)
          end

          it "displays correct rating" do
            expect(page).to have_content("You rated this thought: brilliant")
          end
        end
      end
    end

    # context "with AJAX", :js=>true do

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

  context "a Post" do
    let(:user) { FactoryGirl.create(:user) }
    let(:post) { FactoryGirl.create(:post, id: 5) }
    before do
      sign_in user
      visit new_post_response_path(post)
    end

    it { should have_selector('form#new_rating', :count => 4) }

    describe "clicking 'weak'" do
      before { click_button 'weak' }
    
      it { should have_content("You rated this thought: weak") }

      it "should update post author's score" do
        # post.user.reload -> (true)
        expect(post.user(true).score).to eq 2
      end
    end

    describe "clicking 'average'" do
      before { click_button 'average' }

      it { should have_content("You rated this thought: average") }
    end

    describe "clicking 'thought provoking'" do
      before { click_button 'thought provoking' }

      it { should have_content("You rated this thought: thought provoking") }
    end

    describe "clicking 'brilliant'" do
      before { click_button 'brilliant!' }

      it { should have_content("You rated this thought: brilliant!") }

      it "saves a rating" do
        expect(Rating.where(value: 5).count).to eq 1
      end

      it "sends an email to admin" do
        Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
        expect(last_email.to).to include ('a.h.schiller@gmail.com')
      end

      describe "reloading the page" do
        before { visit new_post_response_path(post) }

        it "form is replaced by current user rating" do
          page.has_no_selector?("form#new_rating")
          expect(page).to have_content("You rated this thought: brilliant!")
        end

        ## RatingsHelper - current_user_rating ##
        describe "with an existing rating of the same rateable_id" do
          let(:response) { FactoryGirl.create(:response, id: 5) }
          let(:rating) { response.ratings.new(user_id: user.id, value: 1) }
          before do
            rating.save
            visit new_post_response_path(post)
          end

          it "displays correct rating" do
            expect(page).to have_content("You rated this thought: brilliant")
          end
        end
      end
    end

    # context "with AJAX", :js=>true do

    #   describe "clicking 'thought provoking'" do
    #     before { click_button 'thought provoking' }

    #     it { should have_link('Send a message') }
    #   end

    #   describe "clicking 'brilliant!'" do
    #     before { click_button 'brilliant!' }

    #     it "has links for message and sharing" do
    #       expect(page).not_to have_link('Send a message')
    #       expect(page).to have_selector('div#social_links')
    #     end
    #   end
    # end
  end
end
