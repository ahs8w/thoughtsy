require 'spec_helper'

describe "Messages" do
  subject { page }

  let(:receiver) { FactoryGirl.create(:user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post, user_id: user.id) }
  
  before { sign_in user }

  # describe "Creation with JS:", :js=>true do
  #   let!(:response) { FactoryGirl.create(:response, user_id: receiver.id, post_id: post.id) }
  #   before do
  #     visit response_path(response)
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