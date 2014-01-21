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
  it { should respond_to(:image) }
  it { should respond_to(:token_timer) }
  it { should respond_to(:unavailable_users) }
  it { should respond_to(:responders) }
  it { should respond_to(:sort_date) }
  it { should respond_to(:ratings) }
  it { should respond_to(:raters) }
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

## Relationships ##
  describe "#responders" do
    let(:response) { FactoryGirl.create(:response, post_id: @post.id) }
    let(:second_response) { FactoryGirl.create(:response, post_id: @post.id) }
    before { @post.save }

    it "displays users who have responded to a post" do
      expect(@post.responders).to include second_response.user
      expect(@post.responders).to include response.user
    end
  end
  
  describe "#raters" do
  end

## Methods ##
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

  describe "[Heroku Scheduler] ::check_expirations" do
    before do
      @post.save
      @post.accept!
    end

    describe "before 24 hours" do
      before { Timecop.freeze(Time.now + 23.hours) }

      it "post state is unchanged" do
        Post.check_expirations
        @post.reload
        expect(@post).to be_pending
      end
    end

    describe "after 24 hours" do
      before { Timecop.freeze(Time.now + 24.hours) }

      context "unanswered" do
        
        it "resets post state to 'unanswered'" do
          Post.check_expirations
          @post.reload
          expect(@post).to be_unanswered
          expect(@post.token_timer).to be_nil
        end

        # Updates user score only after visiting home page (need current_user)

        describe "with existing responses" do
          let!(:response) { FactoryGirl.create(:response, post_id: @post.id) }

          it "returns post state to 'answered'" do
            Post.check_expirations
            @post.reload
            expect(@post).to be_answered
          end
        end
      end

      context "answered" do
        before do
          @post.answer!
        end

        it "post state remains unchanged" do
          Post.check_expirations
          @post.reload
          expect(@post).to be_answered
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

  # describe "#respondable? and #avg_score" do
  #   functionality tested in 'Post State' section as an after answer! callback
  # end

## Callbacks ##
  describe "::after_create" do
    before do
      Timecop.freeze
      @post.save
    end

    it "updates author's score" do
      user.reload
      expect(user.score).to eq 1
    end

    it "adds author to unavailable_users" do
      expect(@post.unavailable_users).to include(user.id)
    end

    it "sets sort_date" do
      expect(@post.sort_date).to eq @post.created_at
    end
  end

## Post Scopes ##
  describe "ordered scopes" do
    let!(:newer_post) { FactoryGirl.create(:post) }
    let!(:older_post) { FactoryGirl.create(:post) }

    before do
      newer_post.update_column(:sort_date, 5.minutes.ago)
      older_post.update_column(:sort_date, 5.hours.ago)
    end

    it ".ascending" do                # Queue
      expect(Post.ascending.first).to eq older_post
    end

    it ".descending" do               # Index
      expect(Post.descending.first).to eq newer_post
    end
  end

  describe "state scopes" do
    let!(:pending) { FactoryGirl.create(:post, state: 'pending') }
    let!(:user_post) { FactoryGirl.create(:post, user_id: user.id, state: 'unanswered') }
    let!(:unqueued) { FactoryGirl.create(:post, state: 'unqueued') }
    let!(:answered) { FactoryGirl.create(:post, state: 'answered') }
    let!(:unanswered) { FactoryGirl.create(:post, state: 'unanswered') }
    let!(:flagged) { FactoryGirl.create(:post, state: 'flagged') }

    it ".answerable" do
      expect(Post.queued.answerable(user)).not_to include(user_post, pending, unqueued)
      expect(Post.queued.answerable(user)).to include(unanswered, answered)
    end

    it ".queued" do
      expect(Post.queued).not_to include(unqueued, pending, flagged)
      expect(Post.queued).to include(user_post, unanswered, answered)
    end

    it ".answered" do
      expect(Post.answered).not_to include(user_post, pending, unanswered)
      expect(Post.answered).to include(answered, unqueued)
    end

    it ".personal" do
      expect(Post.personal).not_to include(answered, unqueued)
      expect(Post.personal).to include(flagged, pending, unanswered)
    end

    it ".ascending.ordered" do
      pending.update_attribute(:sort_date, 1.minute.ago)
      answered.update_attribute(:sort_date, 5.minutes.ago)
      flagged.update_attribute(:sort_date, 3.minutes.ago)
      unanswered.update_attribute(:sort_date, 10.minute.ago)
      user_post.update_attribute(:sort_date, 1.minutes.ago)
      expect(Post.ascending.ordered).to eq([unanswered, user_post, answered, flagged, pending, unqueued])
    end
  end

  describe "Queue" do
    describe "with an answerable post" do
      let!(:user_post) { FactoryGirl.create(:post, user_id: user.id) }
      let!(:user_answered) { FactoryGirl.create(:post, state: 'answered') }
      let!(:answered) { FactoryGirl.create(:post, state: 'answered') }   
      before { user_answered.add_unavailable_users(user) }

      it "yields answerable post" do
        expect(Post.answerable(user).ordered.first).to eq(answered)
      end

      describe "with an unanswered post" do
        let!(:unanswered) { FactoryGirl.create(:post, state: 'unanswered') }

        it "yields unanswered" do
          expect(Post.answerable(user).ordered.first).to eq(unanswered)
        end

        describe "with sort_dates" do
          let!(:earlier_answered) { FactoryGirl.create(:post, state: 'answered') }
          before do
            earlier_answered.update_attribute(:sort_date, 5.minutes.ago)
            answered.update_attribute(:sort_date, 1.minute.ago)
          end

          it "yields earlier_answered" do
            expect(Post.answerable(user).ascending.ordered).to eq([unanswered, earlier_answered, answered])
          end
        end
      end
    end
  end

## Post State ##
  describe "state and transitions" do
    
    it "initial state is :unanswered" do
      expect(@post).to be_unanswered
    end

    describe "#accept!" do
      before { @post.accept! }

      it "changes state to :pending" do
        expect(@post).to be_pending
      end

      it "sets token_timer" do
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
    end

    describe "#answer!" do
      before { @post.save }

      context "an answered post" do
        let!(:response) { FactoryGirl.create(:response, post_id: @post.id) }
        let!(:second_response) { FactoryGirl.create(:response, post_id: @post.id) }

        before do
          Timecop.freeze
          @post.answer!
        end
        
        its(:respondable?) { should eq true }

        it "changes state to :answered" do
          expect(@post).to be_answered
        end

        it "sets sort_date" do
          expect(@post.sort_date).to eq Time.zone.now
        end

        describe "#unanswer!" do
          before { @post.unanswer! }

          it "changes state to :unanswered" do
            expect(@post).to be_unanswered
          end
        end

        context "with three responses" do
          let!(:third_response) { FactoryGirl.create(:response, post_id: @post.id) }

          context "and no ratings" do
            its(:respondable?) { should eq false }
            before { @post.answer! }

            it "changes state to :unqueued" do
              expect(@post).to be_unqueued
            end
          end

          context "and an avg score < 4" do
            let!(:rating) { FactoryGirl.create(:rating, rateable_id: @post.id, rateable_type: 'Post', value: 3) }
            before { @post.answer! }

            it "changes state to :unqueued" do
              expect(@post).to be_unqueued
            end
          end

          context "and an avg score = 4" do
            let!(:second_rating) { FactoryGirl.create(:rating, rateable_id: @post.id, rateable_type: 'Post', value: 5) }
            before { @post.answer! }

            its(:respondable?) { should eq true }

            it "changes state to :answered" do
              expect(@post).to be_answered
            end
          end
        end
      end
    end

    describe "#flag" do
      before { @post.flag! }

      it "changes state to :flagged" do
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
  end
end
