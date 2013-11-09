require 'spec_helper'

describe "ResponsePages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post, created_at: 2.minutes.ago) }
  before { sign_in user }

  describe "new page" do
    let!(:user_post) { FactoryGirl.create(:post, user: user, content: "fake", created_at: 5.minutes.ago) }
    before do
      visit root_path
      click_button "Respond"
    end

    it { should_not have_content(user_post.content) }
    it { should have_content(post.content) }
    it { should have_selector('#time_explanation') }
    it { should have_link("offensive or inappropriate?") }
    it { should have_button("follow") }
    it { should have_selector('#new_response') }
  end

  describe "create action" do
    before do
      visit root_path
      click_button "Respond"
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
      end

      it "has an error message" do
        click_button "Respond"
        expect(page).to have_error_message("error")
      end
    end

    describe "with valid information" do
      before do
        fill_in 'response_content', with: "Lorem Ipsum"
      end

      it "creates a response" do
        expect { click_button "Respond" }.to change(Response, :count).by(1)
        expect(page).to have_title("Thoughtsy")
      end

      # it "resets user tokens" do
      #   click_button "Respond"
      #   user.reload
      #   expect(user.token_timer).to be_blank
      #   expect(user.token_id).to be_blank
      # end

      # it "sends response email" do
      #   click_button "Respond"
      #   expect(last_email.to).to include(post.user.email)
      # end

      # describe "follower_response_email" do
      #   let(:follower) { FactoryGirl.create(:user) }
      #   before { follower.subscribe!(post) }

      #   it "sends email (to admin) with bcc's" do
      #     click_button "Respond"
      #     expect(last_email.bcc).to include(follower.email)
      #   end
      # end
    end

    describe "with image" do
      before { attach_file('response[image]', "#{Rails.root}/spec/support/test.png") }

      it "creates a response" do
        expect { click_button "Respond" }.to change(Response, :count).by(1)
        expect(page).to have_title("Thoughtsy")
      end
    end

    describe "after 'following' post" do
      let(:other_user) { FactoryGirl.create(:user) }
      before do
        user.subscribe!(post)
        fill_in 'response_content', with: "Lorem Ipsum"
      end

      it "updates certain attributes" do
        expect(post.state).to eq 'subscribed'
        click_button "Respond"
        post.reload
        expect(post.state).to eq 'reposted'
        expect(other_user.not_subscribed).to eq post
        expect(user.not_subscribed).not_to eq post
      end

      ## Should be in Mailer Spec? ##
      # it "sends email to followers not including responder" do
      #   click_button "Respond"
      #   expect(last_email.bcc).not_to include(user.email)
      # end
    end
  end

  describe "show page" do
    let!(:user_post) { FactoryGirl.create(:post, user_id: user.id) }
    let(:response) { FactoryGirl.create(:response, post_id: user_post.id) }
    before { visit response_path(response) }

    it { should have_title('Response') }
    it { should have_content(response.content) }
    it { should have_content(response.user.username) }
    it { should have_content(user_post.content) }

    describe "rating form access" do

      context "as post author" do
        it { should have_selector("div#rating_form") }
      end

      context "as post follower" do
        let(:follower) { FactoryGirl.create(:user) }
        before do
          sign_in follower
          follower.subscribe!(user_post)
          visit response_path(response)
        end

        it { should have_selector("div#rating_form") }

        context "as guest" do
          before do
            follower.unsubscribe!(user_post)
            visit response_path(response)
          end

          it { should_not have_selector("div#rating_form") }
        end
      end

      context "as response author" do
        before do
          sign_in response.user
          response.user.subscribe!(user_post)
          visit response_path(response)
        end

        it { should_not have_selector("div#rating_form") }
      end
    end
  end
end
