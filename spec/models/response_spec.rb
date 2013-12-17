require 'spec_helper'

describe Response do
  include CarrierWaveDirect::Test::Helpers
  
  let(:user) { FactoryGirl.create(:user) }
  let(:poster) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post, user: poster, content: "blah", 
                                  created_at: 2.hours.ago, updated_at: 2.hours.ago) }

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

  context "with blank content" do
    before { @response.content = " " }

    context "and no image" do
      it { should_not be_valid }
    end

    context "and an image" do
      before { @response.key = sample_key(ImageUploader.new) }
      it { should be_valid }
    end
  end

  describe "#update_all" do

    context "with no followers" do
      before { @response.update_all }

      it "updates post state and user tokens" do
        post.reload
        expect(post.state).to eq 'answered'
        expect(user.token_id).to eq nil
      end

      it "sends email to responder" do
        Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
        expect(last_email.to).to include(post.user.email)
      end
    end

    context "with several followers" do
      let(:follower) { FactoryGirl.create(:user) }
      let(:follower2) { FactoryGirl.create(:user) }
      before do
        follower.subscribe!(post)
        follower2.subscribe!(post)
        user.subscribe!(post)
        @response.update_all
      end

      it "sends follower email to followers" do
        Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
        expect(ActionMailer::Base.deliveries.size).to eq 3
      end

      it "does not send follower email to responder" do
        Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers
        expect(last_email.to).not_to include(user.email)
      end
    end
  end

  describe "#enqueue_image" do
    Delayed::Worker.delay_jobs = true

    before do
      @response.key = sample_key(ImageUploader.new)
      @response.image = 'image.jpg'
      @response.save
    end

    it "queues up a worker" do
      @response.enqueue_image
      expect(Delayed::Job.count).to eq 1
    end

    # it "processes image and changes column" do          # too slow to run regularly
    #   @response.enqueue_image
    #   Delayed::Worker.new.work_off
    #   @response.reload
    #   expect(@response.image_processed).to eq true
    # end
  end

  ## Response Scopes ##
  describe "ordered scopes" do
    let!(:newer_response) { FactoryGirl.create(:response, created_at: 5.minutes.ago) }
    let!(:older_response) { FactoryGirl.create(:response, created_at: 5.hours.ago) }

    it "ascending" do
      expect(Response.ascending.first).to eq older_response
    end

    it "descending" do
      expect(Response.descending.first).to eq newer_response
    end
  end
end
