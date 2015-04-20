class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :signed_in?, :current_user

  def index
    @messageboard = Thredded::Messageboard.first
  end

  def signed_in?
    current_user.present?
  end

  def current_user
    return nil unless session[:user_id]

    @current_user ||= Thredded.user_class.find(session[:user_id])
  end
end
