require 'spec_helper'

describe Post do
  
  let(:user) { FactoryGirl.create(:user) }
  before { @post = user.posts.build(content: "Lorem Ipsum") }

  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:response) }
  it { should respond_to(:state) }
  it { should respond_to(:unanswered?) }
  it { should respond_to(:pending?) }
  it { should respond_to(:answered?) }
  its(:user) { should eq user }
  its(:state) { should eq "unanswered" }

  it { should be_valid }

  context "when user_id is not present" do
    before { @post.user_id = nil }
    it { should_not be_valid }
  end

  context "with blank content" do
    before { @post.content = " " }
    it { should_not be_valid }
  end

## Response Associations (has_many)##
  # describe "response associations" do
  #   before { @post.save }
  #   let(:user2) { FactoryGirl.create(:user) }
  #   let!(:older_response) { FactoryGirl.create(:response, user: user2, post: @post, created_at: 1.day.ago) }
  #   let!(:newer_response) { FactoryGirl.create(:response, user: user2, post: @post, created_at: 1.hour.ago) }

  #   it "should have the right responses in the right order" do
  #     expect(@post.responses.to_a).to eq [newer_response, older_response]
  #   end
  # end

## Post State ##
  describe "states :" do
    
    describe ":unanswered" do

      it "should be the initial state" do
        expect(@post).to be_unanswered
      end

      it "should change to :pending on #accept" do
        @post.accept!
        expect(@post).to be_pending
      end
    end

    describe ":pending" do
      before { @post.accept! }

      it "should change to :unanswered on #expire" do
        @post.expire!
        expect(@post).to be_unanswered
      end

      it "should change to :answered on #answer" do
        @post.answer!
        expect(@post).to be_answered
      end
    end

    describe ":answered" do
      before { @post.answer! }

      it "should change to :unanswered on #unanswer" do
        @post.unanswer!
        expect(@post).to be_unanswered
      end

## send_response_email ##
      it "should send_response_email" do
        expect(last_email.to).to include(@post.user.email)
      end
    end
  end
end
