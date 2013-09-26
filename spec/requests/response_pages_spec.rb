require 'spec_helper'

describe "ResponsePages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post) }
  before { sign_in user }

  describe "index page" do
    let!(:response) { FactoryGirl.create(:response, post: post) }
    before { visit responses_path }

    it { should have_title('Responses') }
    it { should have_content('Responses') }
    it { should have_content(response.content) }
    it { should have_content(response.user.username) }
    it { should have_content(response.post.user.username) }
    it { should have_content(response.post.content) }

    # describe "pagination" do
    #   before(:all) { 31.times { FactoryGirl.create(:response) } }
    #   after(:all)  { Post.delete_all }
    #   after(:all)  { Response.delete_all }

    #   it { should have_selector('div.pagination') }

    #   it "should list each post" do
    #     Response.paginate(page: 1).each do |response|
    #       expect(page).to have_selector('li', text: response.content)
    #     end
    #   end
    # end  
  end

  describe "response creation" do
    before { visit root_path }

    it "should update the state of corresponding post to 'pending'" do
      expect(post).to be_unanswered
      click_button "Respond to a thought"
      post.reload
      expect(post).to be_pending
    end

    it "should start the #response_timer and set #pending_response_id for user" do
      click_button "Respond to a thought"
      user.reload
      expect(user.response_timer).to be_present
      expect(user.pending_response_id).to eq post.id
    end

    context "from one's own post" do
      let!(:earlier_post) { FactoryGirl.create(:post, user: user, content: "fake", created_at: 5.minutes.ago) }

      it "should not occur" do
        click_button "Respond to a thought"
        expect(page).not_to have_content(earlier_post.content)
      end
    end

    describe "with invalid information" do
      before { click_button "Respond to a thought" }

      it "should not create a response" do
        expect { click_button "Respond" }.not_to change(Response, :count)
      end

      it "should have an error message" do
        click_button "Respond"
        expect(page).to have_error_message("error")
      end

      it "should not change the post state" do
        click_button "Respond"
        post.reload
        expect(post).to be_pending
      end
    end

    describe "with valid information" do
      before do
        click_button "Respond to a thought"
        fill_in 'response_content', with: "Lorem Ipsum"
      end

      it "should create a response" do
        expect { click_button "Respond" }.to change(Response, :count).by(1)
      end

      it "should update the state of corresponding post to 'answered'" do
        click_button "Respond"
        post.reload
        expect(post).to be_answered
      end

      it "should send_request_email" do
        click_button "Respond"
        expect(last_email.to).to include(post.user.email)
      end

      it "should reset temp. user attributes" do
        click_button "Respond"
        user.reload
        expect(user.response_timer).to be_nil
        expect(user.pending_response_id).to be_nil
      end
    end
  end

## response_timer and pending_response_id ##
  describe "response creation after 24hrs have passed" do
    let(:expired_user) { FactoryGirl.create(:user, response_timer: 25.hours.ago) }
    before do
      sign_in expired_user
      visit root_path
      click_button "Respond to a thought"
      fill_in 'response_content', with: "Lorem Ipsum"
    end

    # it "should not create a response" do
    #   expect { click_button "Respond" }.not_to change(Response, :count).by(1)
    # end

    it "should update post state to 'unanswered'" do
      post.reload
      expect(post).to be_pending
      click_button "Respond"
      post.reload
      expect(post).to be_unanswered
    end

    it "should reset temp user attributes to nil" do
      expired_user.reload
      expect(expired_user.pending_response_id).to eq post.id
      click_button "Respond"
      expired_user.reload
      expect(expired_user.pending_response_id).to be_nil
      expect(expired_user.response_timer).to be_nil
    end
  end

  describe "response-post persistance(within 24 hours)" do
    let(:post2) { FactoryGirl.create(:post, content: "blah") }
    before do
      visit root_path
      click_button "Respond to a thought"
    end

    it "the same pending post should persist for the user" do
      expect(page).to have_content(post.content)
      visit root_path
      click_button "Respond to a thought"
      expect(page).to have_content(post.content)
    end
  end

  describe "delete links:" do
    let!(:response) { FactoryGirl.create(:response) }
    let(:admin) { FactoryGirl.create(:admin) }

    it { should_not have_link('delete') }

    describe "admin" do
      before do
        sign_in admin
        visit responses_path
      end

      it { should have_link('delete', href: response_path(response)) }

      context "clicking delete" do

        it "should delete response" do
          expect do
            click_link('delete', match: :first)
          end.to change(Response, :count).by(-1)

          expect(page).to have_success_message('Response destroyed!')
        end

        it "should return the post to the queue and reset state" do
          expect(response.post).to be_answered    # checking factories set up correctly
          click_link('delete', match: :first)
          visit posts_path
          expect(page).to have_content(response.post.content)
          response.post.reload
          expect(response.post).to be_unanswered
        end
      end
    end
  end  
end
