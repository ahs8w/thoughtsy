require 'spec_helper'

# describe "Messages" do
#   subject { page }

#   let(:user) { FactoryGirl.create(:user) }
#   let(:post) { FactoryGirl.create(:post, user_id: user.id) }
  
#   before { sign_in user }

#   describe "Creation with JS:", :js=>true do
#     let!(:response) { FactoryGirl.create(:response, post_id: post.id) }
#     before { visit response_path(response) }

#     describe "clicking 'brilliant!'" do
#       before { click_button 'brilliant!' }

#       it { should have_link('send a note') }

#       ## Message Controller ##
#       describe "-> send a note" do
#         before { click_link("send a note") }
#         it { should have_content("Note to #{response.user.username}") }

#         describe "sending note" do
#           before do
#             fill_in 'message_content', with: "message"
#           end

#           it "saves with correct attributes" do
#             # click_button 'Send'
#             # expect(Message.count).to eq 1
#             expect{ click_button 'Send' }.to change(Message, :count).by(1)
#           end
#         end
#       end
#     end
#   end
# end