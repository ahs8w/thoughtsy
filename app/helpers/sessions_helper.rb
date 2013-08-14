module SessionsHelper

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user    # assignment function
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def signed_in?
    !current_user.nil?          # signed_in? -> true  if current_user is not nil
  end

  def current_user=(user)       # syntax for defining an assignment function
    @current_user = user 
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
      # '||=' sets @current_user variable to user w/ corresponding remember_token only if not already set
  end
end
