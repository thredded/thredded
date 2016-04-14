# frozen_string_literal: true
class SessionsController < ApplicationController
  def new
  end

  def create
    session[:user_id] = Thredded.user_class.where(name: params[:name])
      .first_or_initialize.tap { |user| user.update!(admin: params[:admin]) }.id
    if request.referer != new_session_url
      redirect_back fallback_location: root_path
    else
      redirect_to root_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
