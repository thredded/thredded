class UsersController < ApplicationController
  def show
    @slug = params[:id].to_s
  end
end
