require 'spec_helper'

describe Response do
  
  let(:user) { FactoryGirl.create(:user) }
  let(:poster) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post, user: poster, content: "blah") }

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

  describe "after save callback" do
    before { @response.save }

    it "updates attributes" do
      post.reload
      expect(post.state).to eq 'answered'
      expect(user.token_id).to eq nil
    end

    it "sends email to responder" do
      expect(last_email.to).to include(post.user.email)
    end
  end

  describe "after save callback with several followers" do
    let(:follower) { FactoryGirl.create(:user) }
    let(:follower2) { FactoryGirl.create(:user) }
    before do
      follower.subscribe!(post)
      follower2.subscribe!(post)
      user.subscribe!(post)
      @response.save
    end

    it "sends follower email to followers" do
      expect(ActionMailer::Base.deliveries.size).to eq 3
    end

    it "does not send follower email to responder" do
      expect(last_email.to).not_to include(user.email)
    end
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
