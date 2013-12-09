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

    describe "user order" do
      let!(:new_user) { FactoryGirl.create(:user, score: 5) }
      before { visit users_path }

      it "higher score is at the top" do
        expect(find('ul.users').first('li')).to have_content("#{new_user.username}")
      end
    end
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    
    context "as correct user" do

      before do
        sign_in user
        visit user_path(user)
      end

      it "should have correct layout" do
        expect(page).to have_content("#{user.username} | #{user.score}")
        expect(page).to have_title(user.username)
        expect(page).to have_link("Settings", href: edit_user_path(user))
        expect(page).to have_link("Messages", href: user_messages_path(user))
        expect(page).to have_button("Stats")
        expect(page).to have_content("no answered thoughts")
        expect(page).to have_content("no unanswered thoughts")
      end

      describe "with content" do
        let!(:answered_post) { FactoryGirl.create(:post, user: user, content: "Answered", 
                                                  state: 'answered', updated_at: 4.hours.ago) }
        let!(:unanswered_post) { FactoryGirl.create(:post, user: user, content: "Unanswered", 
                                                    updated_at: 3.hours.ago) }

        let!(:user_response) { FactoryGirl.create(:response, user_id: user.id) }
        before { visit user_path(user) }

        describe "display" do
          it "has content of thoughts" do
            expect(page).to have_link(answered_post.content)
            expect(page).to have_link(unanswered_post.content)
            expect(page).to have_link(user_response.content)
          end
        end

        describe "post order" do
          let!(:newer_post) { FactoryGirl.create(:post, user: user, content: "Newer", updated_at: 3.minutes.ago) }
          before { visit user_path(user) }

          it "is newest to oldest(updated_at)" do
            expect(find('.personal_posts').first('.thought')).to have_content(newer_post.content)
          end
        end

        # describe "thought stats", js: true do
        #   before do
        #     FactoryGirl.create(:rating, response: user_response)
        #     FactoryGirl.create(:subscription, user: user)
        #     visit user_path(user)
        #     click_button "Thought Stats"
        #   end

        #   it "displays dropdown stats menu" do
        #     expect(page).to have_content("Responses: 1")
        #     expect(page).to have_content("Average rating: 3")
        #     expect(page).to have_content("Reposts: 1")
        #     expect(page).to have_content("Answered: 1")
        #     expect(page).to have_content("Unanswered: 1")
        #   end
        # end

        context "as wrong user" do
          let(:wrong_user) { FactoryGirl.create(:user) }

          before do
            sign_in wrong_user
            visit user_path(user)
          end

          it "should have correct layout and display" do
            expect(page).to have_content("#{user.username} | #{user.score}")
            expect(page).to have_title(user.username)
            expect(page).not_to have_link("Settings", href: edit_user_path(user))
            expect(page).not_to have_link("Messages", href: user_messages_path(user))
            expect(page).not_to have_button("Stats")
            expect(page).to have_content("Answered thoughts")
            expect(page).to have_link(answered_post.content)
            expect(page).to have_link(user_response.content)
            expect(page).not_to have_content("Unanswered thoughts")
            expect(page).not_to have_link(unanswered_post.content)
          end
        end
      end

      describe "profile links" do
        it "clicking settings directs to settings page" do
          find('.user_stats').click_link "Settings"
          expect(page).to have_content "Update your profile"
        end

        it "clicking messages directs to messages page" do
          find('.user_stats').click_link "Messages"
          expect(page).to have_content "Personal Messages"
        end
      end

      # describe "pagination" do
      #   before do
      #     6.times { FactoryGirl.create(:post, user: user) }
      #     visit user_path(user)   # necessary to revisit profile page if not using before(:all)
      #   end
      #   after(:all)  { Post.delete_all }

      #   it { should have_selector('div.pagination') }
      # end
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

        it "redisplays form with error messages" do
          expect(page).to have_content("Username can't be blank")
          expect(page).to have_content("Password can't be blank")
          expect(page).to have_content("Email can't be blank")
          expect(page).to have_content("Email is invalid")
        end
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

        it { should have_link("Post") }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      find('ul.navbar-right').click_link "#{user.username}"
      click_link "Settings"
    end


    describe "page" do
      it { should have_content("Update your profile") }
      it { should have_title("Edit profile") }
      it { should have_link('update user image', href: 'http://gravatar.com/emails') }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }

      it "redisplays form with error messages" do
        expect(page).to have_content("form contains 1 error")
        expect(page).to have_content("Password is too short")
      end
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
      it { should have_info_message("Profile updated") }
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
