# frozen_string_literal: true
class UsersController < ApplicationController
  def show
    @slug = params[:id].to_s
  end
end
