require 'spec_helper'

describe Rating do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:post) { FactoryGirl.create(:post) }
  before { @rating = Rating.new(user_id: user.id, rateable_id: post.id, rateable_type: 'post', value: 2) }

  subject { @rating }

  it { should respond_to(:rateable_type) }
  it { should respond_to(:rateable_id) }
  it { should respond_to(:user) }
  its (:user) { should eq user }
  it { should respond_to(:value) }

  it { should be_valid }

  describe "capitalizing rateable_type" do
    before { @rating.save }

    its (:rateable) { should eq post }
  end

  describe "user cannot rate the same thought twice" do
    before { @rating.save }

    it "results in validation error" do
      @rating_double = Rating.new(user_id: user.id, rateable_id: post.id, rateable_type: 'Post', value: 4)
      expect(@rating_double).not_to be_valid
    end
  end
end
