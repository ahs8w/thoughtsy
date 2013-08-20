class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]
  
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Thoughtsy!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def update
    if @user.update_attributes(user_params)
      sign_in @user           # remember_token is reset when user is saved -> must sign_in again after update
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
      # flash[:error] is default action when validation fails
    end
  end


  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    ## Before filters ##

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find(params[:id])  # common to both edit and update actions -> refactored to shared before filter
      redirect_to(root_url) unless current_user?(@user)
    end
end
