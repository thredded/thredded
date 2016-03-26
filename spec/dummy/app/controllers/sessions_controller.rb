class SessionsController < ApplicationController
  def new
  end

  def create
    session[:user_id] = Thredded.user_class.where(name: params[:name])
      .first_or_initialize.tap { |user| user.update!(admin: params[:admin]) }.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
