require 'spec_helper'

describe "ResponsePages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post, created_at: 2.minutes.ago) }
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

  describe "response creation:" do
    before { visit root_path }

    describe "from one's own post" do
      let!(:earlier_post) { FactoryGirl.create(:post, user: user, content: "fake", created_at: 5.minutes.ago) }

      it "should not occur" do
        click_button "Respond"
        expect(page).not_to have_content(earlier_post.content)
      end
    end

    describe "with invalid information" do
      before { click_button "Respond" }

      it "should not create a response" do
        expect { click_button "Respond" }.not_to change(Response, :count)
      end

      it "should have an error message" do
        click_button "Respond"
        expect(page).to have_error_message("error")
      end
    end

    describe "with valid information" do
      before do
        click_button "Respond"
        fill_in 'response_content', with: "Lorem Ipsum"
      end

      it "should create a response" do
        expect { click_button "Respond" }.to change(Response, :count).by(1)
        expect(page).to have_title("Thoughtsy")
      end

      it "should reset user tokens" do
        click_button "Respond"
        user.reload
        expect(user.token_timer).to be_blank
        expect(user.token_id).to be_blank
      end

      it "should send response email" do
        click_button "Respond"
        expect(last_email.to).to include(post.user.email)
      end

      describe "follower_response_email" do
        let(:follower) { FactoryGirl.create(:user) }
        before { follower.subscribe!(post) }

        it "sends email (to admin) with bcc's" do
          click_button "Respond"
          expect(last_email.bcc).to include(follower.email)
        end
      end
    end
  end
  
  describe "response deletion:" do
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

  describe "show page" do
    let(:post) { FactoryGirl.create(:post, user_id: user.id) }
    let(:response) { FactoryGirl.create(:response, post_id: post.id) }
    before { visit response_path(response) }

    it { should have_title('Response') }
    it { should have_content(response.content) }
    it { should have_content(response.user.username) }
    it { should have_content(response.post.user.username) }
    it { should have_content(response.post.content) }
    it { should have_selector("div#rating_form") }

    describe "as user other than post author" do
      let(:user2) { FactoryGirl.create(:user) }
      before do
        sign_in user2
        visit response_path(response)
      end

      it { should_not have_selector("div#rating_form") }
    end
  end
end
