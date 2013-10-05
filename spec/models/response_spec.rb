require 'spec_helper'

describe Response do
  
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post, user: user2, content: "blah") }

  before { @response = user.responses.build(content: "blahblah", post_id: post.id) }

  subject { @response }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should eq user }
  it { should respond_to(:post_id) }
  it { should respond_to(:post) }
  its(:post) { should eq post }
  it { should respond_to(:ratings) }
  it { should respond_to(:raters) }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @response.user_id = nil }
    it { should_not be_valid }
  end

  describe "when post_id is not present" do
    before { @response.post_id = nil }
    it { should_not be_valid }
  end

  describe "with blank content" do
    before { @response.content = ' ' }
    it { should_not be_valid }
  end
end
