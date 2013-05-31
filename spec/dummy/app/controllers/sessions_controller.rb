class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.where(name: params[:name]).first
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
