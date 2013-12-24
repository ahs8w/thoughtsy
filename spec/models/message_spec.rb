require 'spec_helper'

describe Message do
  let(:user) { FactoryGirl.create(:user) }
  let(:receiver) { FactoryGirl.create(:user) }
  before { @message = user.messages.build(content: 'message', receiver_id: receiver.id) }

  subject { @message }

  it { should respond_to(:user) }
  its(:user) { should eq user }
  it { should respond_to(:receiver_id) }
  it { should respond_to(:content) }
  it { should respond_to(:receiver) }
  its(:receiver) { should eq receiver }
  it { should respond_to(:viewed?) }
  its(:viewed?) { should eq false }

  it { should be_valid }

  describe "when content is not present" do
    before { @message.content = nil }
    it { should_not be_valid }
  end

  describe "when receiver_id is not present" do
    before { @message.receiver_id = nil }
    it { should_not be_valid }
  end

  it "has a valid factory" do
    message = FactoryGirl.create(:message)
    expect(message).to be_valid
  end

  describe "#set_viewed?" do
    before { @message.set_viewed? }
    specify { expect(@message.viewed?).to eq true }
  end

  describe "scope" do
    it ".unread" do
      @message.save
      expect(Message.unread).to include @message
      @message.set_viewed?
      @message.reload
      expect(Message.unread).not_to include @message
    end
  end

  describe "#send_email" do
    before { @message.send_email }
    
    it "sends email to message receiver" do
      Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
      expect(last_email.to).to eq([receiver.email])
    end
  end
end
