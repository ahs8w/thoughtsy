require 'spec_helper'

describe "StaticPages" do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end
  
  describe "Home page" do
    before { visit root_path }

    let(:heading)    { 'Thoughtsy' }
    let(:page_title) { '' }
    it_should_behave_like "all static pages"

    describe "when not signed in" do
      it { should_not have_link("Users") }
      it { should_not have_button("Post") }
      it { should_not have_button("Respond to a thought") }
      it { should_not have_link("view my profile") }
      it { should have_link("Sign up now!") }
      it { should have_link("Sign in") }
    end

    describe "when signed in" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:post, user: user)
        sign_in user
        visit root_path
      end

      it { should have_button("Post") }
      it { should_not have_link('Sign up now!', href: signup_path) }
      it { should_not have_link('Sign in',      href: signin_path) }
      it { should have_link("#{user.username}") }
      it { should have_link('Thoughts') }

      describe "the sidebar" do

        it "should singularize one post correctly" do
          expect(page).to have_content("1 post")
        end

        describe "with multiple posts" do
          before do
            FactoryGirl.create(:post, user: user)
            FactoryGirl.create(:post, user: user)            
            sign_in user
            visit root_path
          end

          it "should pluralize correctly" do
            expect(page).to have_content("3 posts")
          end
        end
      end
    end

    ## views/shared/_respond_button ##
    describe "Response button behavior" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:post, user: user)
        sign_in user
        visit root_path
      end

      describe "with no token_timer" do

        context "and no available posts" do

          it { should_not have_button("Respond") }
          it { should have_content("currently no unanswered posts available") }
        end

        context "and an available post" do
          let!(:available) { FactoryGirl.create(:post) }
          before { visit root_path }

          it { should have_button("Respond") }
        end
      end

      describe "with valid token_timer" do
        let!(:token_response) { FactoryGirl.create(:post) }
        before do
          user.token_timer = 12.hours.ago
          user.token_id = token_response.id
          user.save
          visit root_path
        end

        it { should have_button("Respond") }
        it { should have_content("until your response expires!") }
      end

      describe "with expired token_timer" do
        let!(:token_response) { FactoryGirl.create(:post, state: 'pending') }
        before do
          user.token_timer = 25.hours.ago
          user.token_id = token_response.id
          user.save
          visit root_path
        end

        it "updates user tokens and score" do
          user.reload
          expect(user.token_timer).to be_nil
          expect(user.token_id).to be_nil
          expect(user.score).to eq -2
        end

        context "and no available posts" do
          it { should have_content("Your response expired") }
          it { should_not have_button("Respond") }
        end
      end

      describe "and an available post" do
        let!(:available) { FactoryGirl.create(:post, state: 'unanswered') }
        let!(:token_response) { FactoryGirl.create(:post, state: 'pending') }
        before do
          user.token_timer = 25.hours.ago
          user.token_id = token_response.id
          user.save
          visit root_path
        end
        
        it { should have_content("Click the button to get another thought.") }
        it { should have_button("See a new thought") }
      end
    end
  end

  describe "Notification Area" do
    let(:user) { FactoryGirl.create(:user) }
    let(:post) { FactoryGirl.create(:post, user_id: user.id) }
    before do
      sign_in user
      visit root_path
    end

    context "with no notices" do
      it { should_not have_link("unread message") }
      it { should_not have_link("unrated response") }
    end

    context "with notices" do
      let!(:message) { FactoryGirl.create(:message, receiver_id: user.id) }
      let!(:response) { FactoryGirl.create(:response, post_id: post.id) }
      before do
        post.subscribe!   # testing subscribed responses as well
        post.answer!
        visit root_path
      end

      it "has links to appropriate pages" do
        expect(page).to have_link("1 unread message", href: message_path(message))
        expect(page).to have_link("1 unrated response", href: post_path(post))
      end

      context "with multiple notices" do
        let!(:message2) { FactoryGirl.create(:message, receiver_id: user.id) }
        let!(:response2) { FactoryGirl.create(:response, post_id: post.id) }
        before { visit root_path }

        it "pluralizes and links to profile" do
          expect(page).to have_link("2 unread messages", href: user_path(user))
          expect(page).to have_link("2 unrated responses", href: user_path(user))
        end
      end
    end
  end

## Auxillary Pages ##
  describe "About page" do
    before { visit about_path }

    let(:heading)    { 'How it works' }
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
    click_link "How it works"
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
