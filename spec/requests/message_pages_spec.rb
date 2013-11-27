require 'spec_helper'

describe "Message Pages" do
  subject { page }

  let(:sender) { FactoryGirl.create(:user) }
  let(:user) { FactoryGirl.create(:user) }
  
  before { sign_in user }

  describe "Index page" do
    let!(:message) { FactoryGirl.create(:message, user_id: sender.id, receiver_id: user.id) }

    describe "as message receiver" do
      before { visit user_messages_path(user) }
      
      it { should have_title("Messages") }
      it { should have_link("From: #{sender.username}") }
      it { should have_selector("div.strong") }
      it { should have_content(message.content) }
      it { should have_link("Reply") }
      it { should have_link("Return", href: user_path(user)) }

      describe "Replying" do
        before { click_link "Reply" }

        context "with invalid information" do
          it "redirects back and displays error" do
            click_button "Send"
            expect(page).to have_error_message("Message cannot be blank!")
          end
        end

        context "with valid information" do
          before do
            fill_in 'message_content', with: "reply"
            click_button "Send"
          end

          it "sends a reply to sender" do
            expect(page).to have_success_message("Message sent!")
            expect(Message.count).to eq 2
          end

          describe "as message sender" do
            before do
              sign_in sender
              visit user_messages_path(sender)
            end

            it { should have_content("To: #{user.username}") }
            it { should have_link("From: #{user.username}") }
          end
        end
      end
    end
  end

  # describe "Message creation with JS:", :js=>true do
  #   let(:post) { FactoryGirl.create(:post, user_id: user.id) }
  #   let!(:response) { FactoryGirl.create(:response, user_id: sender.id, post_id: post.id) }
  #   before do
  #     visit post_path(post)
  #     click_button "brilliant!"
  #   end

  #   it { should have_link('Send a message') }

  #   describe "-> send a message" do
  #     before { click_link("Send a message") }

  #     it { should have_content("Message to #{sender.username}") }

  #     describe "with invalid information" do
  #       before { click_button "Send" }

  #       it { should have_content("error") }
  #     end

  #     describe "with valid information" do
  #       before do
  #         fill_in 'message_content', with: "message"
  #       end
        
  #       it "clicking 'Send' saves message" do
  #         expect{ click_button 'Send' }.to change(Message, :count).by(1)
  #         expect(page).to have_content('You rated this article: brilliant!')
  #         expect(page).to have_selector('#js_flash_messages', text: 'Message sent!')
  #       end
  #     end
  #   end
  # end

  # describe "Reply creation with JS:", :js=>true do
  #   let!(:message) { FactoryGirl.create(:message, user_id: sender.id, receiver_id: user.id) }
  #   let!(:sent_message) { FactoryGirl.create(:message, user_id: user.id, receiver_id: sender.id) }
  #   before do
  #     visit user_messages_path(user)
  #   end

  #   it "clicking received message sets viewed? and removes strong tag" do
  #     click_link "From:"
  #     message.reload
  #     expect(message.viewed?).to eq true
  #     expect(page).not_to have_selector('div.strong')
  #   end

  #   it "clicking sent message doesn't affect viewed?" do
  #     click_link "To:"
  #     message.reload
  #     expect(message.viewed?).to eq false
  #   end 
  # end
end