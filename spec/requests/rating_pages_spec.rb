require 'spec_helper'

### Response#Show ###

describe "Ratings" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post, user_id: user.id) }
  
  before { sign_in user }

  describe "Creation:" do
    let(:response) { FactoryGirl.create(:response, post_id: post.id) }
    before { visit response_path(response) }

    it "form:" do
      page.has_xpath?("//form.new_rating")
    end

    describe "clicking 'weak'" do
      before { click_button 'weak' }
    
      it { should have_content("You rated this article: weak") }
    end

    describe "clicking 'average'" do
      before { click_button 'average' }

      it { should have_content("You rated this article: average") }
    end

    describe "clicking 'thought provoking'" do
      before { click_button 'thought provoking' }

      it { should have_content("You rated this article: thought provoking") }

      it "does not send an email" do
        expect(last_email).to be_nil
      end
    end

    describe "clicking 'brilliant'" do
      before { click_button 'brilliant!' }

      it { should have_content("You rated this article: brilliant!") }

      it "saves a rating" do
        expect(Rating.where(value: 4).count).to eq 1
      end

      it "sends an email to admin" do
        expect(last_email.to).to include ('admin@thoughtsy.com')
      end

      describe "reloading the page" do
        before { visit response_path(response) }

        it "form is replaced by current rating" do
          page.has_no_xpath?("//form.new_rating")
          expect(page).to have_content("You rated this article: brilliant!")
        end
      end
    end
  end

  # describe "Creation with JS:", :js=>true do
  #   let(:response) { FactoryGirl.create(:response, post_id: post.id) }
  #   before { visit response_path(response) }

  #   describe "clicking 'weak'" do
  #     before { click_button 'weak' }
    
  #     it { should have_link("repost this thought") }

  #     describe "-> repost" do
  #       before { click_link("repost this thought") }
  #       it { should have_success_message("Thought reposted.") }
  #       it { should have_button("Post a thought") }

  #       it "post state is 'unanswered'" do
  #         expect(post.state).to eq 'unanswered'
  #       end
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
