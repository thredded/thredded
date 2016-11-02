# frozen_string_literal: true
class SessionsController < ApplicationController
  self.store_location_fullpath = false

  def new
  end

  def create
    session[:user_id] = Thredded.user_class.find_or_initialize_by(name: params[:name])
      .tap { |user| user.update!(admin: params[:admin]) }.id
    redirect_to clear_stored_location_fullpath! ||
                (request.referer != new_user_session_url && request.referer) ||
                root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
