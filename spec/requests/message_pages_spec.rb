require 'spec_helper'

describe "Message Pages" do
  subject { page }

  let(:receiver) { FactoryGirl.create(:user) }
  let(:user) { FactoryGirl.create(:user) }
  
  before { sign_in user }

  describe "Show page" do

    context "as note receiver" do
      let!(:message) { FactoryGirl.create(:message, user_id: receiver.id, receiver_id: user.id) }
      before do
        visit user_path(user)
        click_link("From: #{receiver.username}")
      end
          
      it { should have_title("Messages") }
      it { should have_content("From: #{receiver.username}") }
      it { should have_content(message.content) }
      it { should have_link("Reply") }
      it { should have_link("Return", href: user_path(user)) }

      it "sets viewed? token to true" do
        message.reload
        expect(message.viewed?).to eq true
      end
    end

    context "as note sender" do
      let!(:message) { FactoryGirl.create(:message, user_id: user.id, receiver_id: receiver.id) }
      before do
        visit user_path(user)
        click_link("To: #{receiver.username}")
      end

      it { should have_content("To: #{receiver.username}") }
      it { should_not have_link("Reply") }
    end
  end

  # describe "Creation with JS:", :js=>true do
  #   let(:post) { FactoryGirl.create(:post, user_id: user.id) }
  #   let!(:response) { FactoryGirl.create(:response, user_id: receiver.id, post_id: post.id) }
  #   before do
  #     visit post_path(post)
  #     click_button "brilliant!"
  #   end

  #   it { should have_link('send a note') }

  #   describe "-> send a note" do
  #     before { click_link("send a note") }

  #     it { should have_content("Note to #{receiver.username}") }

  #     describe "with invalid information" do
  #       before { click_button "Send" }

  #       it { should have_error_message("error") }
  #     end

  #     describe "with valid information" do
  #       before do
  #         fill_in 'message_content', with: "message"
  #       end
        
  #       it "clicking 'Send' saves note" do
  #         expect{ click_button 'Send' }.to change(Message, :count).by(1)
  #         expect(page).to have_content('You rated this article: brilliant!')
  #         expect(page).to have_selector('#js_flash_messages', text: 'Note sent!')
  #       end
  #     end
  #   end
  # end
end