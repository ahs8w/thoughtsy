require 'spec_helper'

describe Post do
  
  let(:user) { FactoryGirl.create(:user) }
  before { @post = user.posts.build(content: "Lorem Ipsum") }

  subject { @post }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:responses) }
  it { should respond_to(:state) }
  it { should respond_to(:unanswered?) }
  it { should respond_to(:pending?) }
  it { should respond_to(:answered?) }
  it { should respond_to(:flagged?) }
  it { should respond_to(:subscriptions) }
  it { should respond_to(:followers) }
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

    describe ":flagged" do
      before { @post.flag! }

      it "changes to :flagged on #flag" do
        @post.flag!
        expect(@post).to be_flagged
      end

      # it "sends an email to admin" do
      #   expect(last_email.to).to include(admin)
      # end
    end

    describe ":answered" do
      before { @post.answer! }

      it "should change to :unanswered on #unanswer" do
        @post.unanswer!
        expect(@post).to be_unanswered
      end
    end
  end

## Post Subscriptions ##
  describe "user.subscribe!" do
    let(:other_user) { FactoryGirl.create(:user) }
    before { @post.save }

    it "adds user to 'followers'" do
      other_user.subscribe!(@post)
      expect(@post.followers).to include(other_user)
    end

    describe "user.unsubscribe!" do
      before { other_user.subscribe!(@post) }

      it "removes user from 'followers'" do
        other_user.unsubscribe!(@post)
        expect(@post.followers).not_to include(other_user)
      end
    end
  end
end
