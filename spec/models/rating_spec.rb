require 'spec_helper'

describe Rating do
  let(:user) { FactoryGirl.create(:user) }

  context "A response" do
    let(:response) { FactoryGirl.create(:response, id: 5) }
    before { @rating = Rating.new(user_id: user.id, rateable_id: response.id, rateable_type: 'Response', value: 1) }

    subject { @rating }

    it { should respond_to(:rateable_id) }
    it { should respond_to(:rateable_type) }
    it { should respond_to(:rateable) }
    its (:rateable) { should eq response }
    it { should respond_to(:user) }
    its (:user) { should eq user }
    it { should respond_to(:value) }

    it { should be_valid }

    describe "cannot rate the same response twice" do
      before { @rating.save }

      it "results in validation error" do
        @rating_double = Rating.new(user_id: user.id, rateable_id: response.id, rateable_type: 'Response', value: 4)
        expect(@rating_double).not_to be_valid
      end
    end

    describe "and a post with the same id" do
      let(:post) { FactoryGirl.create(:post, id: 5) }
      before { @rating.save }

      it "does not set off validation error" do
        @post_rating = Rating.new(user_id: user.id, rateable_id: post.id, rateable_type: 'Post', value: 4)
        expect(@post_rating).to be_valid
      end
    end

    describe "as the author" do
      let!(:user_response) { FactoryGirl.create(:response, user_id: user.id) }
      before { @user_rating = user.ratings.new(rateable_id: user_response.id, rateable_type: 'Response', value: 2) }

      it "is not valid" do
        expect(@user_rating).not_to be_valid
      end
    end

    describe "after create" do

      context "rated 'weak'" do
        before { @rating.save }

        it "updates response author's score" do
          expect(response.user(true).score).to eq 1
        end
      end

      context "rated 'brilliant'" do
        before do
          @rating.value = 5
          @rating.save
        end

        it "updates response author's score" do
          expect(response.user(true).score).to eq 5
        end
      end
    end
  end

  context "A post" do
    let(:post) { FactoryGirl.create(:post, id: 5) }
    before { @rating = Rating.new(user_id: user.id, rateable_id: post.id, rateable_type: 'Post', value: 1) }

    subject { @rating }

    it { should respond_to(:rateable) }
    its (:rateable) { should eq post }

    it { should be_valid }

    describe "cannot rate the same post twice" do
      before { @rating.save }

      it "results in validation error" do
        @rating_double = Rating.new(user_id: user.id, rateable_id: post.id, rateable_type: 'Post', value: 4)
        expect(@rating_double).not_to be_valid
      end
    end

    describe "as the author" do
      let!(:user_post) { FactoryGirl.create(:post, user_id: user.id) }
      before { @user_rating = user.ratings.new(rateable_id: user_post.id, rateable_type: 'Post', value: 2) }

      it "is not valid" do
        expect(@user_rating).not_to be_valid
      end
    end

    describe "after create" do

      context "rated 'weak'" do
        before { @rating.save }

        it "updates post author's score" do
          expect(post.user(true).score).to eq 2     # already at 1 from post creation
        end
      end
    end
  end
end
