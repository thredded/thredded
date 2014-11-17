class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :signed_in?, :current_user

  def index
  end

  def signed_in?
    current_user.present?
  end

  def current_user
    if session[:user_id]
      @current_user ||= Thredded.user_class.find(session[:user_id])
    end
  end
end
