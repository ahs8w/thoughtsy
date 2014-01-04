require 'spec_helper'
# Delayed::Worker.delay_jobs = true   # test that DJ jobs are created and timing is correct

describe Post do
  include CarrierWaveDirect::Test::Helpers
  
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
  it { should respond_to(:reposted?) }
  it { should respond_to(:subscriptions) }
  it { should respond_to(:followers) }
  it { should respond_to(:image) }
  it { should respond_to(:token_timer) }
  it { should respond_to(:unavailable_users) }
  it { should respond_to(:responders) }
  it { should respond_to(:answered_at) }
  its(:user) { should eq user }
  its(:state) { should eq "unanswered" }
  its(:token_timer) { should be_nil }

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
      before { @post.key = sample_key(ImageUploader.new) }
      it { should be_valid }
    end
  end

  describe "#responders" do
    let(:response) { FactoryGirl.create(:response, post_id: @post.id) }
    let(:second_response) { FactoryGirl.create(:response, post_id: @post.id) }
    before { @post.save }

    it "displays users who have responded to a post" do
      expect(@post.responders).to include second_response.user
      expect(@post.responders).to include response.user
    end
  end

  describe "#add_unavailable_users" do
    let(:user2) { FactoryGirl.create(:user) }
    before { @post.save }

    it "adds a user to the array" do
      expect(@post.unavailable_users).to eq [user.id]
      @post.add_unavailable_users(user2)
      expect(@post.unavailable_users).to eq [user.id, user2.id]
      # @post.add_unavailable_users(user)
      # expect(@post.unavailable_users).to eq [user2.id, user.id]
    end
  end

  describe "#remove_unavailable_users" do
    let(:user2) { FactoryGirl.create(:user) }
    before do
      @post.save
      @post.add_unavailable_users(user2)
      # @post.add_unavailable_users(user)
    end

    it "removes user from the array" do
      expect(@post.unavailable_users).to eq [user.id, user2.id]
      @post.remove_unavailable_users(user2)
      expect(@post.unavailable_users).to eq [user.id]
    end
  end

  describe "::check_expirations" do
    before do
      @post.save
      @post.accept!
    end

    describe "before 24 hours" do
      before { Timecop.freeze(Time.now + 23.hours) }

      it "post state is unchanged" do
        Post.check_expirations
        @post.reload
        expect(@post.state).to eq 'pending'
      end

    end

    describe "after 24 hours" do
      before { Timecop.freeze(Time.now + 24.hours) }

      context "without a response" do
        
        it "resets post state to 'unanswered'" do
          Post.check_expirations
          @post.reload
          expect(@post.state).to eq 'unanswered'
        end

        context "with followed post" do
          before do
            user.subscribe!(@post)
            @timestamp = @post.updated_at.day
            Post.check_expirations
          end

          it "resets post state back to 'reposted'" do
            @post.reload
            expect(@post.state).to eq 'reposted'
          end

          it "does not touch update_at column" do
            @post.reload
            expect(@post.updated_at.day).to eq @timestamp
          end
        end
      end

      context "with a response" do
        before do
          @post.answer!
          user.subscribe!(@post)
        end

        it "post state remains unchanged" do
          Post.check_expirations
          @post.reload
          expect(@post.state).to eq 'reposted'
        end
      end
    end
  end

  describe "#set_token_timer" do
    before do
      Timecop.freeze
      @post.set_token_timer
    end

    its(:token_timer) { should eq Time.zone.now }

    describe "#reset_token_timer" do
      before { @post.reset_token_timer }

      its(:token_timer) { should be nil }
    end
  end

  describe "#enqueue_image" do
    Delayed::Worker.delay_jobs = true

    before do
      @post.key = sample_key(ImageUploader.new)
      @post.image = 'image.jpg'
      @post.save
    end

    it "queues up a worker" do
      @post.enqueue_image
      expect(Delayed::Job.count).to eq 1
    end

    # it "processes image and changes column" do          # too slow to run regularly
    #   @post.enqueue_image
    #   Delayed::Worker.new.work_off
    #   @post.reload
    #   expect(@post.image_processed).to eq true
    # end
  end

## Callbacks ##
  describe "::after_create" do
    before { @post.save }

    it "updates author's score" do
      user.reload
      expect(user.score).to eq 1
    end

    it "adds author to unavailable_users" do
      expect(@post.unavailable_users).to include(user.id)
    end
  end
## 

## Post Scopes ##
  describe "ordered scopes" do
    let!(:newer_post) { FactoryGirl.create(:post, updated_at: 5.minutes.ago) }
    let!(:older_post) { FactoryGirl.create(:post, updated_at: 5.hours.ago) }

    it ".ascending" do
      expect(Post.ascending.first).to eq older_post
    end

    it ".descending" do
      expect(Post.descending.first).to eq newer_post
    end
  end

  describe "state scopes" do
    let!(:user_post) { FactoryGirl.create(:post, user_id: user.id, state: 'unanswered') }
    let!(:answered) { FactoryGirl.create(:post, state: 'answered') }
    let!(:pending) { FactoryGirl.create(:post, state: 'pending') }
    let!(:unanswered) { FactoryGirl.create(:post, state: 'unanswered') }
    let!(:flagged) { FactoryGirl.create(:post, state: 'flagged') }
    let!(:reposted) { FactoryGirl.create(:post, state: 'reposted', updated_at: 5.minutes.ago) }

    it ".answerable" do
      expect(Post.answerable(user)).not_to include(user_post, answered, pending)
      expect(Post.answerable(user)).to include(unanswered, reposted)
    end

    it "queued" do
      expect(Post.queued).not_to include(answered, pending, flagged)
      expect(Post.queued).to include(user_post, unanswered, reposted)
    end

    it ".answered" do
      expect(Post.answered).not_to include(user_post, pending, unanswered)
      expect(Post.answered).to include(answered, reposted)
    end

    it ".personal" do
      expect(Post.personal).not_to include(answered, reposted)
      expect(Post.personal).to include(flagged, pending, unanswered)
    end
  end

## Post State ##
  describe "state behavior and transitions" do
    
    describe ":unanswered" do

      it "should be the initial state" do
        expect(@post).to be_unanswered
      end

      it "changes state to :pending on #accept" do
        @post.accept!
        expect(@post).to be_pending
      end
    end

    describe ":pending" do
      before { @post.accept! }

      it "#sets token_timer" do
        expect(@post.token_timer).not_to be_nil
      end

      describe "#expire!" do
        before { @post.expire! }

        it "changes state to :unanswered" do
          expect(@post).to be_unanswered
        end

        it "resets token_timer" do
          expect(@post.token_timer).to be_nil
        end
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
        Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
        expect(last_email.to).to include 'a.h.schiller@gmail.com'
      end

      it "updates post author score" do
        user.reload
        expect(user.score).to eq -2
      end
    end

    describe ":reposted" do
      before { @post.subscribe! }

      it "changes to :reposted on #subscribe" do
        expect(@post).to be_reposted
      end

      it "does not change on #expire" do
        @post.expire!
        expect(@post).to be_reposted
      end
    end

    describe ":answered" do
      before do
        Timecop.freeze
        @post.answer!
      end

      it "changes to :answered on #answer" do
        expect(@post).to be_answered
      end

      it "updates answered_at column" do
        expect(@post.answered_at).to eq Time.zone.now
      end

      it "should change to :unanswered on #unanswer" do
        @post.unanswer!
        expect(@post).to be_unanswered
      end

      it "should change to :subscribed on #subscribe" do
        @post.subscribe!
        expect(@post).to be_reposted
      end

      describe "#repost!" do
        before { @post.repost! }

        it "changes state to :reposted" do
          expect(@post).to be_reposted
        end
      end
    end
  end
end
