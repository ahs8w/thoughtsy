class PasswordResetsController < ApplicationController
  def new
  end

  def edit
    @user = User.find_by_password_reset_token(params[:id])
    if @user.nil?
      flash[:danger] = "Invalid password reset token."
      render 'new'
    end
  end

  def create
    @user = User.find_by_email(params[:email])
    if !@user.nil?
      @user.send_password_reset
      flash[:info] = "Email sent with password reset instructions."
      redirect_to :root
    else
      flash[:danger] = "Email address not found in database."
      render 'new'
    end
  end

  def update
    @user = User.find_by!(password_reset_token: (params[:id]))
    if @user.password_reset_sent_at < 2.hours.ago   # setting expiration time
      flash[:warning] = "Password reset has expired."
      redirect_to new_password_reset_path
    elsif @user.update_attributes(password_reset_params)
      sign_in @user
      flash[:success] = "Password has been reset!"
      redirect_to root_url
    else
      render 'edit'
    end
  end

  private

    def password_reset_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
