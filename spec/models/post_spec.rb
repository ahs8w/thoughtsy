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
  it { should respond_to(:subscribed?) }
  it { should respond_to(:followed?) }
  it { should respond_to(:subscriptions) }
  it { should respond_to(:followers) }
  it { should respond_to(:image) }
  its(:user) { should eq user }
  its(:state) { should eq "unanswered" }

  it { should be_valid }

  context "when user_id is not present" do
    before { @post.user_id = nil }
    it { should_not be_valid }
  end

  context "with blank content" do
    before { @post.content = " " }

    context "and no image" do
      it { should_not be_valid }
    end

    context "and an image" do
      before { @post.image = File.open(File.join(Rails.root, "spec/support/test.png")) }
      it { should be_valid }
    end
  end

  describe "after save" do
    before { @post.save }

    it "updates author's score" do
      user.reload
      expect(user.score).to eq 1
    end

    describe "#set_expiration_timer" do
      before { @post.accept! }

      context "if unanswered" do

        it "expires post" do
          expect(@post.state).to eq 'pending'
          @post.set_expiration_timer_without_delay
          expect(@post.state).to eq 'unanswered'
        end
      end

      context "if answered or followed" do
        let(:another_user) { FactoryGirl.create(:user) }
        before do
          another_user.subscribe!(@post)
          @post.answer!
        end

        it "does not change state of post" do
          @post.set_expiration_timer_without_delay
          expect(@post.state).to eq 'followed'
        end
      end
    end
  end

## Post Scopes ##
  describe "ordered scopes" do
    let!(:newer_post) { FactoryGirl.create(:post, created_at: 5.minutes.ago) }
    let!(:older_post) { FactoryGirl.create(:post, created_at: 5.hours.ago) }

    it "ascending" do
      expect(Post.ascending.first).to eq older_post
    end

    it "descending" do
      expect(Post.descending.first).to eq newer_post
    end
  end

  describe "state scopes" do
    let!(:user_post) { FactoryGirl.create(:post, user_id: user.id, state: 'unanswered') }
    let!(:answered_post) { FactoryGirl.create(:post, state: 'answered') }
    let!(:pending_post) { FactoryGirl.create(:post, state: 'pending') }
    let!(:unanswered) { FactoryGirl.create(:post, state: 'unanswered') }
    let!(:flagged) { FactoryGirl.create(:post, state: 'flagged') }
    let!(:subscribed) { FactoryGirl.create(:post, state: 'followed', created_at: 5.minutes.ago) }
    let!(:followed) { FactoryGirl.create(:post, created_at: 10.minutes.ago) }
    let!(:no_state) { FactoryGirl.create(:post) }
    before { user.subscribe!(followed) }

    it "available" do
      expect(Post.available(user)).not_to include(user_post, answered_post, pending_post)
      expect(Post.available(user)).to include(unanswered, subscribed)
    end

    it "answered" do
      subscribed.answer!
      expect(Post.answered).not_to include(user_post, pending_post, unanswered)
      expect(Post.answered).to include(answered_post, subscribed)
    end

    it "personal" do
      expect(Post.personal).not_to include(answered_post)
      expect(Post.personal).to include(flagged, pending_post, unanswered, no_state)
    end

    #user model method
    it "not_subscribed method" do
      expect(user.not_subscribed).to eq subscribed
    end
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
        expect(@post).to be_flagged
      end

      it "sends an email to admin" do
        expect(last_email.to).to include 'admin@thoughtsy.com'
      end

      it "updates post author score" do
        user.reload
        expect(user.score).to eq -2
      end
    end

    describe ":subscribed" do
      before { @post.subscribe! }

      it "changes to :subscribed on #subscribe" do
        expect(@post).to be_subscribed
      end

      it "changes to :followed on #answer" do
        @post.answer!
        expect(@post).to be_followed
      end

      it "changes to :pending on #unsubscribe" do
        @post.unsubscribe!
        expect(@post).to be_pending
      end
    end

    describe ":answered" do
      before { @post.answer! }

      it "should change to :unanswered on #unanswer" do
        @post.unanswer!
        expect(@post).to be_unanswered
      end

      it "should change to :subscribed on #subscribe" do
        @post.subscribe!
        expect(@post).to be_subscribed
      end
    end
  end
end
