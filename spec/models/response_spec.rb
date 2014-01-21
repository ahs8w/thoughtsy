require 'spec_helper'

describe Response do
  include CarrierWaveDirect::Test::Helpers
  
  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post, content: "blah", created_at: 2.hours.ago) }
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
  describe "scopes" do
    let!(:newer_response) { FactoryGirl.create(:response, created_at: 5.minutes.ago) }
    let!(:older_response) { FactoryGirl.create(:response, created_at: 5.hours.ago) }

    it "ascending" do
      expect(Response.ascending.first).to eq older_response
    end

    it "descending" do
      expect(Response.descending.first).to eq newer_response
    end

    it "unrated" do
      expect(Response.unrated).to eq([newer_response, older_response])
    end

    it "unrated_by" do
      expect(Response.unrated_by(user)).to eq([newer_response, older_response])
    end

    describe "with ratings" do
      let!(:user_rating) { FactoryGirl.create(:rating, rateable_id: newer_response.id, rateable_type: 'Response', user_id: user.id) }
      let!(:rating) { FactoryGirl.create(:rating, rateable_id: older_response.id, rateable_type: 'Response') }

      it "unrated_by returns response not rated by user" do
        expect(Response.unrated_by(user)).to eq([older_response])
      end
    end
  end
end
