# frozen_string_literal: true
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
    return unless session[:user_id]
    @current_user ||= Thredded.user_class.find_by_id(session[:user_id]).tap do |user|
      # If the database has been recreated, user_id may be invalid.
      session.delete(:user_id) if user.nil?
    end
  end
end
