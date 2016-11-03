# frozen_string_literal: true
class SessionsController < ApplicationController
  self.store_location_fullpath = false

  def new
  end

  def create
    user = Thredded.user_class.find_or_initialize_by(name: params[:name])
    unless user.update(admin: params[:admin])
      redirect_to(new_user_session_path,
                  alert: user.errors.full_messages.to_sentence) && return
    end
    session[:user_id] = user.id
    redirect_location = clear_stored_location_fullpath! || request.referer
    redirect_location = thredded.root_path if [root_path, root_url, new_user_session_url].include?(redirect_location)
    redirect_to redirect_location,
                notice: "Signed in as #{user.name}, #{(user.admin? ? 'an admin' : ' a user')}."
  end

  def destroy
    session[:user_id] = nil
    redirect_to thredded.root_path, notice: 'Signed out.'
  end
end
