class SessionsController < ApplicationController
  def new
  end

  def create
    user = Thredded.user_class.where(name: params[:name]).first_or_create!
    superduper!(user) if Rails.env.development?

    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  private

  def superduper!(user)
    Thredded::UserDetail.where(user: user).first_or_create(superadmin: true)
  end
end
