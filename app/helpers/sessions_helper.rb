module SessionsHelper

## authentication methods
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

  def current_user=(user)       # syntax for defining an assignment function
    @current_user = user 
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
      # '||=' sets @current_user variable to user w/ corresponding remember_token only if not already set
  end

  def current_user?(user)
    user == current_user
  end

## before filters (post, user controller)
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  # (user, post, response controllers)
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def signed_in?
    !current_user.nil?          # signed_in? -> true  if current_user is not nil
  end

  ## Friendly Forwarding ##
  
  def redirect_back_or(default)                    # used in 'Users#create' 
    redirect_to(session[:return_to] || default)    # redirects to desired page (if it exists) or default
    session.delete(:return_to)                     # remove stored url so subsequent signins don't render protected page
  end

  def store_location                          # used in 'signed_in_user' before filter
    session[:return_to] = request.url         # stores desired page in session hash
  end
end
