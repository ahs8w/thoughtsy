class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      sign_in user
      flash[:success] = "You are now signed in!"
      redirect_back_or user           # friendly forwarding redirection/defaults to user profile
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
