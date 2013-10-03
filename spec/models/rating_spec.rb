require 'spec_helper'

describe Rating do
  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post) }
  let(:response) { FactoryGirl.create(:response) }
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
end
