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

  it { should be_valid }
end
