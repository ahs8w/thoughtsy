require 'spec_helper'

describe "Response pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post, created_at: 2.minutes.ago) }
  before { sign_in user }

  describe "New page" do
    let!(:user_post) { FactoryGirl.create(:post, user: user, content: "fake", created_at: 5.minutes.ago) }
    before do
      visit root_path
      click_link "Respond"
    end

    it { should_not have_content(user_post.content) }
    it { should have_content(post.content) }
    it { should have_selector('#form_hint') }
    it { should have_link("inappropriate post?") }
    it { should have_selector('#new_response') }
    it { should have_link("not your language?") }
    it { should have_selector('div.rating_form') }

    it "sets user tokens" do
      user.reload
      expect(user.token_id).to eq post.id
      expect(user.token_timer).to be_present
    end

    it "changes post state and adds user to unavailable users" do
      post.reload
      expect(post.state).to eq 'pending'
      expect(post.unavailable_users).to include user.id
    end
  end

  describe "create action" do
    before do
      visit root_path
      click_link "Respond"
    end

    describe "with invalid information" do

      it "sets tokens for user" do
        expect(user.token_timer).to be_blank
        user.reload
        expect(user.token_id).to eq post.id
        expect(user.token_timer).to be_present
      end

      it "does not create a response" do
        expect { click_button "Respond" }.not_to change(Response, :count)

        expect(page).to have_content("* Response must include either an image or content")
      end

      context "with post already rated" do
        before { click_button 'weak' }

        it "does not reset rating form" do
          click_button "Respond"
          expect(page).to have_content("* Response must include either an image or content")
          expect(page).to have_content("You rated this")
        end
      end
    end

    describe "with valid information" do
      before do
        fill_in 'response_content', with: "Lorem Ipsum"
      end

      it "creates a response" do
        expect { click_button "Respond" }.to change(Response, :count).by(1)
        expect(page).to have_content(post.content)
      end
    end

    # describe "with image" do
    #   before { attach_file('response[image]', "#{Rails.root}/spec/support/test.png") }

    #   it "creates a response" do
    #     expect { click_button "Respond" }.to change(Response, :count).by(1)
    #     expect(page).to have_title("Thoughtsy")
    #   end
    # end
  end
end
