# frozen_string_literal: true
class SessionsController < ApplicationController
  def new
  end

  def create
    session[:user_id] = Thredded.user_class.find_or_initialize_by(name: params[:name])
      .tap { |user| user.update!(admin: params[:admin]) }.id
    if request.referer != new_user_session_url
      redirect_back fallback_location: root_path, status: 307
    else
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
