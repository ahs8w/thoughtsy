require 'spec_helper'

describe "StaticPages" do
  let(:user) { FactoryGirl.create(:user) }

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end
  
  describe "Home page" do
    let!(:post) { FactoryGirl.create(:post) }
    before { visit root_path }

    let(:heading)    { 'Thoughtsy' }
    let(:page_title) { '' }
    it_should_behave_like "all static pages"

    describe "when not signed in" do
      it { should_not have_link("Users") }
      it { should_not have_link("Post!") }
      it { should_not have_link("Respond!") }
      it { should_not have_link(user.username) }
      it { should have_link("Sign up now!") }
      it { should have_link("Sign in") }
    end

    describe "when signed in" do
      before do
        sign_in user
        visit root_path
      end

      it { should have_link("Post!") }
      it { should have_link("Respond!") }
      it { should_not have_link('Sign up now!', href: signup_path) }
      it { should_not have_link('Sign in',      href: signin_path) }
      it { should have_link(user.username) }
      it { should have_link('Thoughts') }

      describe "::rollback_tokens" do  # timer expired
        before do
          user.update_columns(token_timer: 25.hours.ago, token_id: post.id)
          post.update_columns(token_timer: 25.hours.ago, state: 'pending')
          visit root_path
        end

        it "resets user tokens and updates score" do
          user.reload
          expect(user.token_timer).to be_nil
          expect(user.token_id).to be_nil
          expect(user.score).to eq -3
        end

        it "updates post.unavailable_users" do
          post.reload
          expect(post.unavailable_users).to eq [post.user.id, user.id]
          expect(post.token_timer).to be_nil
        end
      end
    end
  end

  describe "Response button and message" do
    before do
      sign_in user
      visit root_path
    end

    describe "with no token_timer" do

      context "and no available posts" do

        it { should_not have_link("Respond") }
        it { should have_content("currently no unanswered posts available") }
      end

      context "and an available post" do
        let!(:available) { FactoryGirl.create(:post) }
        before { visit root_path }

        it { should have_link("Respond") }
      end
    end

    describe "with token_timer" do
      let!(:accepted_post) { FactoryGirl.create(:post, state: 'pending') }
      before { user.update_attribute(:token_id, accepted_post.id) }

      describe "unexpired" do
        before do
          user.update_attribute(:token_timer, 12.hours.ago)
          visit root_path
        end

        it { should have_link("Respond") }
        it { should have_content("until your response expires!") }

        it "respond button yields accepted_post" do
          click_link "Respond"
          expect(page).to have_content(accepted_post.content)
        end
      end

      describe "expired" do
        before do
          user.update_attribute(:token_timer, 25.hours.ago)
        end

        context "with no available posts" do
          before { visit root_path }

          it { should have_content("Your response expired") }
          it { should have_content("There are currently no unanswered posts available.") }
          it { should_not have_link("Respond") }

          it "post form does not have an error message" do
            expect(page).not_to have_content("* Post must include either an image or content")
          end
        end

        context "with an available post" do
          let!(:available) { FactoryGirl.create(:post) }
          before do
            visit root_path
          end

          it "satisfies conditions [sanity check -> setup is correct]" do
            expect(user.timer_valid).to be_false
            expect(user.posts_available).to be_true
          end

          it { should have_content("Your response expired") }
          it { should have_content("Click the button to get another thought.") }

          it "clicking respond yields available post" do
            click_link "Respond"
            expect(page).to have_content(available.content)
          end
        end

        context "when post has been answered since last visiting" do
          before do
            accepted_post.answer!
            visit root_path
          end

          it { should have_content("Your response expired") }
        end
      end
    end
  end

  describe "Response Queue" do
    before { sign_in user }

    context "as post author and post responder" do
      let!(:user_post) { FactoryGirl.create(:post, user_id: user.id) }
      let(:user_response) { FactoryGirl.create(:response, user_id: user.id) }
      before do
        user_response.post.answer!
        user_response.post.add_unavailable_users(user)    # occurs with accept! action on Response#New
        visit root_path
      end

      it { should_not have_link "Respond" }
    end

    context "with answerable posts" do
      let(:response) { FactoryGirl.create(:response) }
      let!(:answered) { FactoryGirl.create(:post, state: 'answered') }
      before do
        answered.update_attribute(:sort_date, 5.minutes.ago)
        response.post.update_attribute(:sort_date, 1.minute.ago)
        response.post.answer!
        visit root_path
      end

      it "clicking respond yields response.post" do
        click_link "Respond"
        expect(page).to have_content(answered.content)
      end

      context "and unanswered posts" do
        let!(:unanswered) { FactoryGirl.create(:post) }
        let!(:unanswered2) { FactoryGirl.create(:post) }
        before do
          unanswered.update_attribute(:sort_date, 1.minute.ago)
          unanswered2.update_attribute(:sort_date, 5.minutes.ago)
          visit root_path
          click_link "Respond"
        end

        it { should have_content(unanswered2.content) }

        describe "after responding" do
          before do
            fill_in 'response_content', with: "Lorem Ipsum"
            click_button "Respond"
            visit root_path
            click_link "Respond"
          end

          it { should have_content(unanswered.content) }
        end
      end
    end
  end

  describe "Notification Area" do
    let(:post) { FactoryGirl.create(:post, user_id: user.id) }
    let(:user_response) {FactoryGirl.create(:response, user_id: user.id) }
    before do
      sign_in user
      visit root_path
    end

    context "with no notices" do
      it { should_not have_link("notification_message") }
      it { should_not have_link("notification_response") }
    end

    context "with a message notice" do
      let!(:message) { FactoryGirl.create(:message, receiver_id: user.id) }
      before { visit root_path }

      it "has link to message page" do
        expect(find('#notification_message')).to have_link("", href: user_messages_path(user))
        expect(find('#notification_message')['title']).to eq("You have 1 unread message")
      end
    end

    context "with a response notice" do
      let!(:response) { FactoryGirl.create(:response, post_id: post.id) }
      before do
        post.answer!
        visit root_path
      end

      it "has link to post page" do
        expect(find('#notification_response')).to have_link("", href: post_path(post))
      end

      context "with a post response and a communal response" do
        let!(:response2) { FactoryGirl.create(:response, post_id: post.id) }
        let!(:response3) { FactoryGirl.create(:response, post_id: user_response.post.id) }
        before { visit root_path }

        it "pluralizes and links to profile" do
          expect(find('#notification_response')).to have_link("", href: user_path(user))
          expect(find('#notification_response')['title']).to eq("You have 3 unrated responses")
        end

        context "as another responder" do
          before do
            sign_in response.user
            visit root_path
          end

          it "has link to post page" do
            expect(find('#notification_response')).to have_link("", href: post_path(post))
            expect(find('#notification_response')['title']).to eq("You have 1 unrated response")
          end
        end
      end
    end
  end

## Auxillary Pages ##
  describe "About page" do
    before { visit about_path }

    let(:heading)    { 'About' }
    let(:page_title) { 'About' }
    it_should_behave_like "all static pages"
  end

  describe "Team page" do
    before { visit team_path }

    page_info("Team")                           # page_info helper method in utilities.rb
    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }

    page_info("Contact")
    it_should_behave_like "all static pages"
  end

  it "should have the correct links in the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title("About"))
    click_link "Thoughtsy"
    expect(page).to have_title(full_title(""))
    click_link "Team"
    expect(page).to have_title(full_title("Team"))
    click_link "Contact"
    expect(page).to have_title(full_title("Contact"))
    click_link "Thoughtsy"
    click_link "Sign up now!"
    expect(page).to have_title(full_title("Sign up"))
  end
end
