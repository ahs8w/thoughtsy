require 'spec_helper'

describe Post do
  
  let(:user) { FactoryGirl.create(:user) }
  before { @post = user.posts.build(content: "Lorem Ipsum") }

  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:responses) }
  it { should respond_to(:responded_to?) }
  its(:user) { should eq user }

  it { should be_valid }

  describe "when user_id is not present" do
    before { @post.user_id = nil }
    it { should_not be_valid }
  end

  describe "with blank content" do
    before { @post.content = " " }
    it { should_not be_valid }
  end

## Response Associations ##
  describe "response associations" do
    before { @post.save }
    let(:user2) { FactoryGirl.create(:user) }
    let!(:older_response) { FactoryGirl.create(:response, user: user2, post: @post, created_at: 1.day.ago) }
    let!(:newer_response) { FactoryGirl.create(:response, user: user2, post: @post, created_at: 1.hour.ago) }

    it "should have the right responses in the right order" do
      expect(@post.responses.to_a).to eq [newer_response, older_response]
    end
  end  
end
