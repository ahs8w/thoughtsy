require 'spec_helper'

### Response#Show ###

describe "Rating Pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post, user_id: user.id) }
  
  before { sign_in user }

  describe "Creation:" do
    let!(:response) { FactoryGirl.create(:response, post_id: post.id) }
    before { visit post_response_path(post, response) }

    it "form:" do
      page.has_xpath?("//form.new_rating")
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
        expect(last_email.to).to include ('admin@thoughtsy.com')
      end

      describe "reloading the page" do
        before { visit post_response_path(post, response) }

        it "form is replaced by current rating" do
          page.has_no_xpath?("//form.new_rating")
          expect(page).to have_content("You rated this article: brilliant!")
        end
      end
    end
  end

  describe "as response author and post follower" do
    let(:author) { FactoryGirl.create(:user) }
    let!(:author_response) { FactoryGirl.create(:response, user_id: author.id) }
    before do
      author.subscribe!(post)
      sign_in author
    end

    it "rating form does not appear" do
      visit post_response_path(post, author_response)
      expect(page).to have_title "Response"
      expect(page).not_to have_selector("#rating_form")
    end
  end

  # describe "Creation with JS:", :js=>true do
  #   let(:response) { FactoryGirl.create(:response, post_id: post.id) }
  #   before { visit post_response_path(post, response) }

  #   describe "clicking 'weak'" do
  #     context "as post author" do
  #       before { click_button 'weak' }
      
  #       it { should have_link("repost this thought") }

  #       describe "-> repost" do
  #         before { click_link("repost this thought") }
  #         it { should have_success_message("Thought reposted.") }
  #         it { should have_button("Post a thought") }

  #         it "post state is 'unanswered'" do
  #           expect(post.state).to eq 'unanswered'
  #         end
  #       end
  #     end

  #     context "as post follower" do
  #       let(:follower) { FactoryGirl.create(:user) }
  #       before do
  #         follower.subscribe!(post)
  #         sign_in follower
  #         visit post_response_path(post, response)
  #         click_button 'weak'
  #       end

  #       it { should_not have_link("repost this thought") }
  #       it { should have_content("You rated this article: weak")}
  #     end
  #   end

  #   describe "clicking 'thought provoking'" do
  #     before { click_button 'thought provoking' }

  #     it { should have_link('send a note') }
  #   end

  #   describe "clicking 'brilliant!'" do
  #     before { click_button 'brilliant!' }

  #     it { should have_link('send a note') }
  #   end
  # end
end
