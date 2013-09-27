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
  it { should respond_to(:responder_token?)}
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

## checking .answer! transition ##
      it "should send_response_email" do
        expect(last_email.to).to include(@post.user.email)
      end
    end
  end

## custom methods ##
  describe ":responder_token" do
    its(:responder_token) { should eq nil }

    it "should be set with #set_responder_token" do
      @post.set_responder_token(user.id)
      expect(@post.responder_token).to eq user.id
    end
  end

  describe ":reset_responder_token" do
    let(:post) { FactoryGirl.create(:post, responder_token: 1) }

    it "should do as it's named" do
      post.reset_responder_token
      expect(post.responder_token).to be_nil
    end
  end
end
