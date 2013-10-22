require 'spec_helper'

describe "ResponsePages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post, created_at: 2.minutes.ago) }
  before { sign_in user }

  # describe "index page" do
  #   let!(:response) { FactoryGirl.create(:response, post: post, created_at: 5.minutes.ago) }
  #   let!(:newer_response) { FactoryGirl.create(:response, post: post) }
  #   before { visit post_responses_path(post) }

  #   it { should have_title('Responses') }
  #   it { should have_content(response.content) }
  #   it { should have_content(response.user.username) }
  #   it { should have_content(newer_response.content) }
  #   it { should have_content(response.post.user.username) }
  #   it { should have_content(response.post.content) }

  #   describe "response order" do
  #     it "older response is first" do
  #       expect(first('#responses li')).to have_content(response.content)
  #     end
  #   end

  #   describe "#destroy" do
  #     let!(:response) { FactoryGirl.create(:response) }
  #     let(:admin) { FactoryGirl.create(:admin) }

  #     it { should_not have_link('delete') }

  #     describe "admin" do
  #       before do
  #         sign_in admin
  #         visit post_responses_path(response.post)
  #       end

  #       it { should have_link('delete', href: response_path(response)) }

  #       context "clicking delete" do

  #         it "should delete response" do
  #           expect do
  #             click_link('delete', match: :first)
  #           end.to change(Response, :count).by(-1)

  #           expect(page).to have_success_message('Response destroyed!')
  #         end

  #         it "should return the post to the queue and reset state" do
  #           expect(response.post).to be_answered    # checking factories set up correctly
  #           click_link('delete', match: :first)
  #           visit posts_path
  #           expect(page).to have_content(response.post.content)
  #           response.post.reload
  #           expect(response.post).to be_unanswered
  #         end
  #       end
  #     end
  #   end

  #   # describe "pagination" do
  #   #   before(:all) { 31.times { FactoryGirl.create(:response, post_id: post.id) } }
  #   #   after(:all)  { Post.delete_all }
  #   #   after(:all)  { Response.delete_all }
  #   #   after(:all)  { User.delete_all }

  #   #   it { should have_selector('div.pagination') }

  #   #   it "should list each post" do
  #   #     Response.paginate(page: 1).each do |response|
  #   #       expect(page).to have_selector('li', text: response.content)
  #   #     end
  #   #   end
  #   # end  
  # end

  describe "new page" do
    before { visit root_path }

    describe "responding to one's own post" do
      let!(:earlier_post) { FactoryGirl.create(:post, user: user, content: "fake", created_at: 5.minutes.ago) }

      it "will not occur" do
        click_button "Respond"
        expect(page).not_to have_content(earlier_post.content)
      end
    end

    describe "responder links" do
      before { click_button "Respond" }

      it { should have_link("offensive or inappropriate?") }
      it { should have_button("follow") }

      describe "clicking offensive" do
        let!(:post2) { FactoryGirl.create(:post) }
        before { click_link "offensive" }

        it { should have_content(post2.content) }
        it { should have_content("Post flagged.") }

        it "sends an email to admin" do
          expect(last_email.to).to include('admin@thoughtsy.com')
        end
      end
      ## clicking follow is covered in subscription_pages_spec
    end
  end

  describe "#create" do
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

  describe "show page" do
    let(:post) { FactoryGirl.create(:post, user_id: user.id) }
    let(:response) { FactoryGirl.create(:response, post_id: post.id) }
    before { visit post_response_path(post, response) }

    it { should have_title('Response') }
    it { should have_content(response.content) }
    it { should have_content(response.user.username) }
    it { should have_content(response.post.content) }
    it { should have_selector("div#rating_form") }

    # describe "reposting", :js=>true do
    #   before do
    #     post.state = 'answered'
    #     click_button 'weak'
    #   end

    #   it "clicking link changes post state and displays flash" do
    #     click_link "repost this thought?"
    #     post.reload
    #     expect(post.state).to eq 'unanswered'
    #     expect(page).to have_success_message("Thought reposted.")
    #   end
    # end

    describe "access" do
      context "as normal user" do
        let(:user2) { FactoryGirl.create(:user) }
        before do
          sign_in user2
        end

        it "redirects to root" do
         visit post_response_path(post, response)
         expect(page).to have_button('Post a thought')
        end
      end

      context "as post follower" do
        let(:follower) { FactoryGirl.create(:user) }
        before do
          sign_in follower
          follower.subscribe!(post)
        end

        it "renders show page" do
          visit post_response_path(post, response)
          expect(page).to have_selector("div#rating_form")
        end
      end
    end
  end
end
