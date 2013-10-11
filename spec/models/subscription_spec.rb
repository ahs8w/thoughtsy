require 'spec_helper'

describe Subscription do
  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post) }
  let(:subscription) { post.subscriptions.build(user_id: user.id) }

  subject { subscription }

  it { should be_valid }
  it { should respond_to(:user) }
  it { should respond_to(:post) }
  its(:user) { should eq user }
  its(:post) { should eq post }

  describe "when user_id is not present" do
    before { subscription.user_id = nil }
    it { should_not be_valid }
  end

  describe "when post_id is not present" do
    before { subscription.post_id = nil }
    it { should_not be_valid }
  end

end 