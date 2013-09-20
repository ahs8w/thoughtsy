class PasswordResetsController < ApplicationController
  def new
  end

  def edit
    @user = User.find_by_password_reset_token(params[:id])
    if @user.nil?
      flash[:notice] = "Invalid password reset token."
      render 'new'
    end
  end

  def create
    @user = User.find_by_email(params[:email])
    if !@user.nil?
      @user.send_password_reset
      redirect_to :root, :notice => "Email sent with password reset instructions."
    else
      flash[:notice] = "Email address not found in database."
      render 'new'
    end
  end

  def update
    @user = User.find_by!(password_reset_token: (params[:id]))
    if @user.password_reset_sent_at < 2.hours.ago   # setting expiration time
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @user.update_attributes(password_reset_params)
      sign_in @user
      redirect_to root_url, :notice => "Password has been reset!"
    else
      render 'edit'
    end
  end

  private

    def password_reset_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
