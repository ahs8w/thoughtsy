class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
      # necessary to allow methods in sessions_helper.rb to be available in both controllers and views
      # default is for helpers to be available in all views only
      
  after_filter :set_access_control_headers

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'https://thoughtsy.com'
  end
end
