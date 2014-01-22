require 'spec_helper'

describe "UserPages" do
  
  subject { page }

  describe "Index page" do

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

  describe "Profile page" do
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
        let!(:user_response) { FactoryGirl.create(:response, user_id: user.id) }
        let!(:answered) { FactoryGirl.create(:post, user: user, state: 'answered') }
        let!(:unanswered) { FactoryGirl.create(:post, user: user) }
        before do
          visit user_path(user)
        end

        describe "display" do
          it "has content of thoughts" do
            expect(page).to have_link(answered.content)
            expect(page).to have_link(unanswered.content)
            expect(page).to have_link(user_response.content)
          end

          describe "with ratings" do
            let!(:post_rating) { FactoryGirl.create(:rating, rateable_id: answered.id, rateable_type: 'Post', value: 3) }
            let!(:post_rating2) { FactoryGirl.create(:rating, rateable_id: answered.id, rateable_type: 'Post', value: 4) }
            let!(:response_rating) { FactoryGirl.create(:rating, rateable_id: user_response.id, rateable_type: 'Response', value: 5) }
            let!(:response_rating2) { FactoryGirl.create(:rating, rateable_id: user_response.id, rateable_type: 'Response', value: 4) }
            before { visit user_path(user) }

            it "shows badges with average rating" do
              expect(find('div.panel-response')).to have_content(4.5)
              expect(find('div.public_posts').find('div.panel-post')).to have_content(3.5)
            end
          end

          describe "unrated rateable styling" do

            context "with no unrated rateable responses" do
              it "has no extra styling" do
                expect(find('#profile_response')).not_to have_css('#unrated_response')
                expect(find('#profile_post')).not_to have_css('#unrated_response')
              end
            end

            context "with unrated rateable responses" do
              let!(:response_response) { FactoryGirl.create(:response, post_id: user_response.post.id) }
              let!(:post_response) { FactoryGirl.create(:response, post_id: answered.id) }
              before { visit user_path(user) }

              it "shows unrated response panels with border" do
                expect(find('#profile_response')).to have_css('#unrated_response')
                expect(find('#profile_post')).to have_css('#unrated_response')
              end

              describe "after rating response" do
                let!(:rating) { FactoryGirl.create(:rating, rateable_id: post_response.id, rateable_type: 'Response', user_id: user.id, value: 3) }
                before { visit user_path(user) }

                it "styling is removed" do
                  expect(find('#profile_post')).not_to have_css('#unrated_response')
                end
              end
            end

            context "with an existing response" do
              let!(:response) { FactoryGirl.create(:response) }

              context "a new user response" do
                let!(:new_user_response) { FactoryGirl.create(:response, post_id: response.post.id, user_id: user.id) }
                before { visit user_path(user) }

                it "has unrated styling" do
                  expect(find('#unrated_response')).to have_content(new_user_response.content)
                end
              end
            end
          end
        end

        describe "order" do
          context "public posts" do
            before do
              answered.update_column(:sort_date, 4.hours.ago)
              visit user_path(user)
            end

            it "newest is first" do
              expect(find('.public_posts').first('.panel-focus')).to have_content(user_response.content)
            end
          end

          context "personal posts" do
            let!(:older_unanswered) { FactoryGirl.create(:post, user: user) }
            before do
              unanswered.update_column(:sort_date, 2.hours.ago)
              older_unanswered.update_column(:sort_date, 3.hours.ago)
              visit user_path(user)
            end

            it "newest is first" do
              expect(find('.personal_posts').first('.thought')).to have_content(unanswered.content)
            end
          end
        end

        # describe "thought stats", js: true do
        #   before do
        #     FactoryGirl.create(:rating, rateable_id: user_response.id, rateable_type: 'Response')
        #     FactoryGirl.create(:rating, rateable_id: user_response.id, rateable_type: 'Response', value: 4)
        #     FactoryGirl.create(:rating, rateable_id: answered.id, rateable_type: 'Post', value: 2)
        #     visit user_path(user)
        #     click_button "Thought Stats"
        #   end

        #   it "displays dropdown stats menu", focus:true do
        #     expect(page).to have_content("Responses: 1")
        #     expect(find('#average_response_rating')).to have_content("Average rating: 3.5")
        #     expect(page).to have_content("Answered: 1")
        #     expect(page).to have_content("Unanswered: 1")
        #     expect(find('#average_post_rating')).to have_content("Average rating: 2")
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
            expect(page).to have_link(answered.content)
            expect(page).to have_link(user_response.content)
            expect(page).not_to have_content("Unanswered thoughts")
            expect(page).not_to have_link(unanswered.content)
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

  describe "Signup page" do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "Signup" do
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

      describe "after submitting" do
        before { click_button submit }

        it { should have_link("Post") }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }

        it "sends welcome email" do
          Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
          expect(last_email.subject).to eq("Welcome to Thoughtsy")
        end
      end
    end
  end

  describe "Edit page" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      find('ul.navbar-right').click_link "#{user.username}"
      click_link "Settings"
    end

    it { should have_content("Update your profile") }
    it { should have_title("Edit profile") }
    it { should have_link('update user image', href: 'http://gravatar.com/emails') }

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
