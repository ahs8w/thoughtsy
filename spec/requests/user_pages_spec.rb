require 'spec_helper'

describe "UserPages" do
  
  subject { page }

  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before do
      sign_in user
      visit users_path
    end

    it { should have_title("Users") }
    it { should have_content("Users") }

    # describe "pagination" do
    #   before do
    #     31.times { FactoryGirl.create(:user) }
    #     visit users_path
    #   end
    #   after(:all)  { User.delete_all }

    #   it { should have_selector('div.pagination') }

    #   it "should list each user" do
    #     User.paginate(page: 1).each do |user|
    #       expect(page).to have_selector('li', text: user.username)
    #     end
    #   end
    # end

    describe "delete_links" do

      it { should_not have_link('delete') }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
        it { should_not have_link('delete', href: user_path(:admin)) }
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    let(:wrong_user) { FactoryGirl.create(:user) }
    # let! -> creates and instantiates variable
    let!(:answered_post) { FactoryGirl.create(:post, user: user, content: "Answered", 
                                              state: 'answered', created_at: 4.hours.ago) }
    let!(:unanswered_post) { FactoryGirl.create(:post, user: user, content: "Unanswered", created_at: 3.hours.ago) }
    let!(:newer_post) { FactoryGirl.create(:post, user: user, content: "New", created_at: 3.minutes.ago) }

    let!(:user_message) { user.messages.create(content: "sent", to_id: wrong_user.id) }
    let!(:received_message) { Message.create(content: "received", to_id: user.id, user_id: wrong_user.id) }

    let!(:response) { FactoryGirl.create(:response, post_id: answered_post.id) }
    let!(:user_response) { FactoryGirl.create(:response, user_id: user.id) }

    describe "with no posts" do
      before do
        sign_in user
        visit user_path(wrong_user)
      end

      it { should have_content('There are no answered thoughts') }
    end

    describe "as wrong user" do
      before do
        sign_in wrong_user
        visit user_path(user)
      end

      it { should have_content(user.username) }
      it { should have_title(user.username) }
      it { should_not have_link("edit settings", href: edit_user_path(user)) }
      it { should_not have_content("Notes") }

      context "posts" do
        it { should have_content(answered_post.content) }
        it { should_not have_content(unanswered_post.content) }
      end

      context "responses" do 
        it { should have_content(response.content) }
        it { should have_content(user_response.content) }
      end

      context "thought counts" do
        it { should_not have_xpath('.//h4', text: 'Posts (3)') }
        it { should_not have_xpath('.//h4', text: 'Responses (1)') }
      end

      context "messages" do
        it { should_not have_content(user_message.content) }
        it { should_not have_content(received_message.content) }
      end  

        # describe "pagination" do
        #   before do
        #     31.times { FactoryGirl.create(:post, user: user) }
        #     visit user_path(user)   # necessary to revisit profile page if not using before(:all)
        #   end
        #   after(:all)  { Post.delete_all }

        #   it { should have_selector('div.pagination') }
        # end
    end

    describe "as the correct user" do
      before do
        sign_in user
        visit user_path(user)
      end

      it { should have_link("edit settings", href: edit_user_path(user)) }
      it { should have_content(user.responses.count) }
      it { should have_content(user.posts.count) }
      it { should have_content(unanswered_post.content) }

      context "counts are correct" do
        it { should have_xpath('.//h4', text: 'Posts (3)') }
        it { should have_xpath('.//h4', text: 'Responses (1)') }
      end

      it "posts are ordered newest to oldest" do
        expect(first('#personal_posts li')).to have_content(newer_post.content)
      end

      context "sent and received messages" do
        it { should have_content(user_message.content) }
        it { should have_content(received_message.content) }
      end
    end
  end

  describe "signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "signup" do
    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_error_message('error') }
      end
    end

    describe "with valid information" do
      before do
        fill_in "Username",         with: "Example User"
        fill_in "Email",            with: "user@example.com"
        fill_in "Password",         with: "foobar"
        fill_in "Confirm Password", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by(email: 'user@example.com') }

        it { should have_title(user.username) }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end


    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit profile") }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it { should have_error_message('error') }
    end

    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "New@EmaiL.CoM" }
      before do
        fill_in "Username",         with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: "foobar"
        fill_in "Confirm Password", with: "foobar"
        click_button "Save changes"
      end

      it { should have_title(new_name) }
      it { should have_success_message("Profile updated") }
      it { should have_link("Sign out", href: signout_path) }
      specify { expect(user.reload.username).to eq new_name }     # check that attributes are indeed changed in database
      specify { expect(user.reload.email).to eq new_email.downcase }
    end

    describe "admin attribute" do
      let(:params) do
        { user: { admin: true, password: user.password,
                  password_confirmation: user.password } }
      end
      before { patch user_path(user), params }
      specify { expect(user.reload).not_to be_admin }
    end
  end
end
