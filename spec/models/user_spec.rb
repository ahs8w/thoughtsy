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
  it { should respond_to(:response_timer?) }
  it { should respond_to(:pending_response_id?) }

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
  describe "return value of authenticate method" do
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

## Post Associations ##
  describe "post association" do
    before { @user.save }
    let!(:older_post) { FactoryGirl.create(:post, user: @user, created_at: 1.day.ago) }
    let!(:newer_post) { FactoryGirl.create(:post, user: @user, created_at: 1.hour.ago) }

    # it "should have the right posts in the right order" do
    #   expect(@user.posts.to_a).to eq [newer_post, older_post]
    # end

    it "should destroy associated posts on user destruction" do
      posts = @user.posts.to_a             # allows us to check if the array of user's posts are still in db
      @user.destroy
      expect(posts).not_to be_empty        # safety check to catch errors if 'to_a' were to be removed
      posts.each do |post|
        expect(Post.where(id: post.id)).to be_empty
      end
    end
  end

## Response Associations and timer ##
  describe "response association" do
    before { @user.save }
    let!(:response) { FactoryGirl.create(:response, user: @user) }

    it "should destroy associated responses on user destruction" do
      responses = @user.responses.to_a
      @user.destroy
      expect(responses).not_to be_empty
      responses.each do |response|
        expect(Response.where(id: response.id)).to be_empty
      end
    end

    context "#set_response_and_timer" do
      before { @user.set_response_and_timer(response.post.id) }

      it "sets response_time on user model" do
        expect(@user.response_timer).to be_present
      end

      it "sets pending_response_id" do
        expect(@user.pending_response_id).to be_present
      end

      context "#reset" do
        before { @user.reset_response_and_timer }

        it "resets user attributes" do
          expect(@user.response_timer).to be_nil
          expect(@user.pending_response_id).to be_nil
        end
      end
    end
  end

## Password Reset ##
  describe "send password reset" do
    before { @user.save }       # all the tests work even without saving the user!!??  WHY??

    it "generates a unique password_reset_token each time" do
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
      expect(last_email.to).to include(@user.email)
    end
  end
end
