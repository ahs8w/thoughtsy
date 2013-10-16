require 'spec_helper'

describe Message do
  let(:user) { FactoryGirl.create(:user) }
  let(:receiver) { FactoryGirl.create(:user) }
  before { @message = user.messages.build(content: 'message', to_id: receiver.id) }

  subject { @message }

  it { should respond_to(:user) }
  its(:user) { should eq user }
  it { should respond_to(:to_id) }
  it { should respond_to(:content) }
  it { should respond_to(:receiver) }
  its(:receiver) { should eq receiver }

  it { should be_valid }

  describe "when content is not present" do
    before { @message.content = nil }
    it { should_not be_valid }
  end

  describe "when to_id is not present" do
    before { @message.to_id = nil }
    it { should_not be_valid }
  end
end
