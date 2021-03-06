class UsersController < ApplicationController
  include ProfileHelper
  
  before_action :signed_in_user,    only: [:index, :edit, :update, :destroy]
  before_action :correct_user,      only: [:edit, :update]
  before_action :admin_user,        only: :destroy
  before_action :already_signed_in, only: [:new, :create]

  def show
    @user = User.find(params[:id])
    @public_posts = public_posts(@user).paginate(page: params[:page], :per_page => 5)
    @personal_posts = @user.posts.personal.descending.paginate(page: params[:page], :per_page => 5)
  end

  def new
    @user = User.new
  end

  def index
    @users = User.score_descending.paginate(page: params[:page])
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Thoughtsy!"
      UserMailer.delay.welcome_email(@user)
      redirect_to root_path
    else
      render 'new'
    end
  end

  def update
    if @user.update_attributes(user_params)
      sign_in @user           # remember_token is reset when user is saved -> must sign_in again after update
      flash[:info] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
      # flash[:error] is default action when validation fails
    end
  end

  def destroy
    to_be_destroyed = User.find(params[:id])
    if current_user != to_be_destroyed
      to_be_destroyed.destroy
      flash[:success] = "User destroyed"
      redirect_to users_url
    else
      flash[:danger] = "Auto-destruction is not allowed"
      redirect_to root_url
    end
  end


  private

    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

## Before filters ##
    def correct_user
      @user = User.find(params[:id])  # common to both edit and update actions -> refactored to shared before filter
      unless current_user?(@user)  
        flash[:info] = "Unauthorized access"
        redirect_to(root_url)
      end
    end

    def already_signed_in
      unless !signed_in?
        flash[:info] = "Unauthorized access"
        redirect_to(root_url)
      end
    end
end
