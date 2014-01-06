require 'spec_helper'

describe User do

  before do
    @user = User.new(username: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }

  it { should respond_to(:username) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin?) }
  it { should respond_to(:posts) }
  it { should respond_to(:responses) }
  it { should respond_to(:token_id?) }
  it { should respond_to(:token_timer?) }
  it { should respond_to(:ratings) }
  it { should respond_to(:response_ratings) }
  it { should respond_to(:messages) }
  it { should respond_to(:received_messages) }
  it { should respond_to(:subscriptions) }
  it { should respond_to(:followed_posts) }
  it { should respond_to(:subscribe!) }
  it { should respond_to(:unsubscribe!) }
  it { should respond_to(:score) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to true" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "when username is not present" do
    before { @user.username = " " }
    it { should_not be_valid }
  end

  describe "when username is too long" do
    before { @user.username = "a" * 51 }
    it { should_not be_valid }
  end

## EMAIL VALIDATIONS ##

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExaMPle.CoM" }

    it "should be saved as all lower case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.email).to eq mixed_case_email.downcase
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup                  # .dup method: creates duplicate user w/ same attributes
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

## PASSWORD VALIDATIONS ##
  
  describe "when password is not present" do
    before do
      @user = User.new(username: "Example User", email: "user@example.com",
                       password: " ", password_confirmation: " ")
    end

    it { should_not be_valid } 
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }

    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

## covering cases of password match and password mismatch with authenticate method
  describe ".authenticate(password)" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    let "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end
    # user.authenticate("password") -> returns user object or false
    # @user(subject) should eq (==) found_user if password is correct

    describe "with invalid password" do
      let(:user_with_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_with_invalid_password }
      specify { expect(user_with_invalid_password).to be_false }
    end
    # @user(subject) should not eq (==) user_with_invalid password if password does not match
  end

## Remember_token for sessions
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
      # applies subsequent test to given attribute of subject
      # equivalent to:  it { expect(@user.remember_token).not_to be_blank }
  end

## Scope ##
  describe "score_descending scope" do
    let!(:second_user) { FactoryGirl.create(:user, score: 10) }
    before do
      @user.save
    end

    it "returns user with highest score first" do
      expect(User.score_descending.first).to eq second_user
    end
  end 

## Post Associations ##
  describe "post-user association" do
    before { @user.save }
    let!(:older_post) { FactoryGirl.create(:post, user: @user, created_at: 1.day.ago) }
    let!(:newer_post) { FactoryGirl.create(:post, user: @user, created_at: 1.hour.ago) }

    # it "should have the right posts in the right order" do
    #   expect(@user.posts.to_a).to eq [newer_post, older_post]
    # end

    it "posts destroyed on user destruction" do
      posts = @user.posts.to_a             # allows us to check if the array of user's posts are still in db
      @user.destroy
      expect(posts).not_to be_empty        # safety check to catch errors if 'to_a' were to be removed
      posts.each do |post|
        expect(Post.where(id: post.id)).to be_empty
      end
    end
  end

## Response Associations ##
  describe "response-user association" do
    before { @user.save }
    let!(:response) { FactoryGirl.create(:response, user: @user) }

    it "responses destroyed on user destruction" do
      responses = @user.responses.to_a
      @user.destroy
      expect(responses).not_to be_empty
      responses.each do |response|
        expect(Response.where(id: response.id)).to be_empty
      end
    end

    describe "through rating" do
      let(:rating) { response.ratings.create(user_id: 5, value: 5) }

      it "user.response_ratings works" do
        expect(@user.response_ratings).to include(rating)
      end
    end
  end

## State Machine Tokens ##
  describe "state machine tokens" do
    
    its(:token_timer) { should be_blank }
    its(:token_id) { should be_blank }

    describe "#set_tokens" do

      context "when blank" do
        before { @user.set_tokens(53) }

        it "sets user tokens" do
          expect(@user.token_timer).to be_present
          expect(@user.token_id).to eq 53
        end

        describe "#reset_tokens" do
          before { @user.reset_tokens }

          it "reset user tokens" do
            expect(@user.token_timer).to be_blank
            expect(@user.token_id).to be_blank
          end
        end
      end

      context "when already defined" do
        before do
          @user.token_timer = 15.minutes.ago
          @user.token_id = 34
          @user.save
        end

        it "does not reset the tokens" do
          @user.set_tokens(53)
          @user.save
          # expect(@user.token_timer).to eq 15.minutes.ago      # works in theory
          expect(@user.token_id).to eq 34
        end
      end
    end
  end

  describe "#timer_valid" do
    before { @user.save }

    context "under 24 hours" do
      it "equals true" do
        @user.token_timer = 12.hours.ago
        @user.save
        expect(@user.timer_valid).to eq true
      end
    end

    context "after 24 hours" do
      it "equals false" do
        @user.token_timer = 25.hours.ago
        @user.save
        expect(@user.timer_valid).to eq false
      end
    end

    context "no token_timer" do
      it "equals false" do
        expect(@user.timer_valid).to eq false
      end
    end
  end

  describe "#posts_available" do
    before { @user.save }
    context "with no unanswered posts" do
      it "equals false" do
        expect(@user.posts_available).to eq false
      end
    end
    context "with unowned unanswered posts" do
      let!(:post) { FactoryGirl.create(:post, state: 'unanswered') }

      it "equals true" do
        expect(@user.posts_available).to eq true
      end
    end
    context "with own unanswered posts" do
      let!(:post) { FactoryGirl.create(:post, user_id: @user.id, state: 'unanswered') }

      it "equals false" do
        expect(@user.posts_available).to eq false
      end
    end 
  end

## Password Reset ##
  describe "#send_password_reset" do
    before { @user.save }       # all the tests work even without saving the user!!??  WHY??

    it "generates a unique password_reset_token" do
      @user.send_password_reset
      last_token = @user.password_reset_token
      @user.send_password_reset
      expect(@user.password_reset_token).not_to eq last_token
    end

    it "saves the time the password reset was sent" do
      @user.send_password_reset
      expect(@user.reload.password_reset_sent_at).to be_present
    end

    it "delivers email to the user" do
      @user.send_password_reset
      Delayed::Worker.new.work_off        ## Rspec 'all' tests failed without workers      
      expect(last_email.to).to include(@user.email)
    end
  end

## Subscriptions ##
  describe "#subscribe!" do
    let(:response) { FactoryGirl.create(:response, user_id: @user.id) }
    before { @user.save }

    it "adds post to 'followed_posts'" do
      @user.subscribe!(response.post)
      expect(@user.followed_posts).to include(response.post)
      expect(response.post.followers).to include(@user)
      expect(response.post.state).to eq 'reposted'
    end

    describe "#unsubscribe!" do
      before { @user.subscribe!(response.post) }

      it "removes post from 'followed_posts'" do
        @user.unsubscribe!(response.post)
        expect(@user.followed_posts).not_to include(response.post)
        expect(response.post.followers).not_to include(@user)
        expect(response.post.state).to eq 'answered'
      end
    end
  end

## Reputation System ##
  describe "#update_score!" do
    it "sets or adds to the user score" do
      @user.update_score!(1)
      @user.update_score!(3)
      expect(@user.score).to eq 4
    end
  end
end
