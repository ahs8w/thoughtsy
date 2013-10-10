require 'spec_helper'

describe Rating do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:response) { FactoryGirl.create(:response) }
  before { @rating = Rating.new(user_id: user.id, response_id: response.id, value: 2) }

  subject { @rating }

  it { should respond_to(:response) }
  its (:response) { should eq response }
  it { should respond_to(:user) }
  its (:user) { should eq user }
  it { should respond_to(:value) }

  it { should be_valid }

  describe "user cannot rate the same response twice" do
    before { @rating.save }

    it "results in validation error" do
      @rating_double = Rating.new(user_id: user.id, response_id: response.id, value: 4)
      expect(@rating_double).not_to be_valid
    end
  end
end