require 'spec_helper'

describe "Authentication  : " do
  subject { page }

  describe "signin page" do
    before { visit signin_path }

    it { should have_title("Sign in") }
    it { should have_content("Sign in") }
   
    describe "with invalid information" do
      before { click_button('Sign in') }

      it { should have_error_message('Invalid') }
      it { should have_title('Sign in') }
      it { should_not have_link('Profile') }
      it { should_not have_link('Settings') }

      # testing flash persistence -> flash.now[:error]
      describe "after visiting another page" do
        before { click_link("Thoughtsy") }
        it { should_not have_error_message('')}
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      ## PROFILE page (redirected after sign_in)
      it { should have_link("Post") }
      it { should have_success_message('signed in') }
      it { should have_link('Users',            href: users_path) }
      it { should have_link('Thoughts',         href: posts_path) }
      it { should have_link('Profile',          href: user_path(user)) }
      it { should have_link('Settings',         href: edit_user_path(user)) }
      it { should have_link('Sign out',         href: signout_path) }
      it { should_not have_link('Sign in',      href: signin_path) }

      describe "followed by signout" do
        before { click_link("Sign out") }
        it { should have_link("Sign in") }
      end
    end
  end

  describe "authorization :" do

    describe "for non signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users Controller" do

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title("Sign in") }
          it { should have_info_message("Please sign in") }
        end

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }

          it { should have_title("Sign in") }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
          # non-Capybara way to access controller actions: issue HTTP request directly; impossible to visit #update directly
          # issues PATCH request to /users/1 -> which is routed to update action of Users controller
          # direct HTTP reqests: grants access to 'response' object which can verify the server response (e.g redirection)
        end

        describe "attempting to visit a protected page" do
          before do
            visit edit_user_path(user) # expect redirect to '/signin'
            sign_in user
          end

          describe "after signing in" do

            it "should render the desired protected page" do      # friendly forwarding
              expect(page).to have_title('Edit profile')
            end

            describe "the second time" do
              before do
                delete signout_path
                sign_in user
              end

              it "renders the default (home) page" do
                expect(page).to have_link("Post")
              end
            end
          end
        end
      end

      describe "in the Posts Controller" do
        describe "submitting to the create action" do
          before { post posts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "visiting the index page" do
          before { visit posts_path }
          it { should have_title('Thoughts') }
        end

        describe "visiting the show page" do
          let(:response) { FactoryGirl.create(:response) }
          before { visit post_path(response.post) }
          it { should have_title('Responses') }
        end
      end

      describe "in the Responses Controller" do

        describe "submitting to the create action" do
          # before { post "posts/1/responses" }      use literal paths w/ nested routes to set proper params
          before { post "posts/1/responses" }
          specify { expect(response).to redirect_to(signin_path) }
        end

        # describe "submitting to the destroy action" do
        #   before { delete response_path(FactoryGirl.create(:response)) }
        #   specify { expect(response).to redirect_to(signin_path) }
        # end

        # describe "visiting the show action" do
        #   before { get "posts/1/responses/1" }
        #   specify { expect(response).to redirect_to(signin_path) }
        # end

        describe "visiting the new action" do
          before { get "posts/1/responses/new" }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "in the Ratings controller" do
        describe "submitting to the create action" do
          before { post ratings_path }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end

      describe "in the Messages Controller" do
        describe "submitting to the create action" do
          before { post messages_path }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end

    describe "as an unauthorized user" do
      let(:wrong_user) { FactoryGirl.create(:user) }
      before { sign_in wrong_user, no_capybara: true }

      describe "in Users Controller" do
        let!(:user) { FactoryGirl.create(:user) }

        describe "visiting edit page" do
          before { visit edit_user_path(user) }
          it { should_not have_title('Edit profile') }
        end

        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end

      describe "in the Posts Controller" do
        let!(:post) { FactoryGirl.create(:post) }

        describe "submitting to the flag action" do
          before { get flag_post_path(post) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end

      # describe "in the Ratings Controller", focus:true do
      #   let(:response) { FactoryGirl.create(:response) }

      #   it "submitting to create action" do
      #     post ratings_path, rating: {rateable_id: response.id, rateable_type: 'Response', user_id: wrong_user.id, value: 3}
      #     expect(response).to redirect_to(root_url)
      #   end
      # end

      describe "in the Responses Controller" do

        describe "submitting to the create action" do
          before { post "posts/1/responses" }
          specify { expect(response).to redirect_to(root_url) }
        end
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }
      let(:post) { FactoryGirl.create(:post) }
      let(:response) { FactoryGirl.create(:response) }

      before { sign_in non_admin, no_capybara: true }

      it { should_not have_link('Queue') }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a DELETE request to the Posts#destroy action" do
        before { delete post_path(post) }
        specify { expect(response).to redirect_to(root_url) }
      end

      # describe "submitting a DELETE request to the Responses#destroy action" do
      #   before { delete response_path(response) }
      #   specify { expect(response).to redirect_to(root_url) }
      # end

      describe "visiting the queue page" do
        before { get queue_path }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "as an admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in admin, no_capybara: true }

      describe "should not be able to delete one's self" do
        before { delete user_path(admin) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "should have Queue link" do
        before { sign_in admin }

        it { should have_link('Queue', href: queue_path) }
      end
    end

    describe "as a signed in user" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user, no_capybara: true }

      describe "cannot access User#new" do
        before { get new_user_path }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "cannot access User#create" do
        before { post users_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
  end
end
