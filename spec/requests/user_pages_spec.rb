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

    describe "pagination" do
      before do
        31.times { FactoryGirl.create(:user) }
        visit users_path
      end
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.username)
        end
      end
    end

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
    let!(:p1) { FactoryGirl.create(:post, user: user, content: "Foo") }  #creates p1 (instantiates it also)
    let!(:p2) { FactoryGirl.create(:post, user: user, content: "Bar") }

    before { visit user_path(user) }

    it { should have_content(user.username) }
    it { should have_title(user.username) }

    describe "when signed in" do
      before { sign_in user }

      it { should have_link("Sign out", href: signout_path) }
      it { should have_link("edit settings", href: edit_user_path(user)) }
      it { should have_link("Respond") }

      describe "responses" do
        let!(:response) { FactoryGirl.create(:response, post: p1) }
        before { visit user_path(user) }

        it { should have_content("#{response.content}") }
      end
    end

    describe "posts" do
      it { should have_content(p1.content) }
      it { should have_content(p2.content) }
      it { should have_content(user.posts.count) }
      it { should_not have_link('delete') }

      describe "pagination" do
        before do
          31.times { FactoryGirl.create(:post, user: user) }
          visit user_path(user)   # necessary to revisit profile page if not using before(:all)
        end
        after(:all)  { Post.delete_all }

        it { should have_selector('div.pagination') }
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
