# frozen_string_literal: true

module Thredded
  class RelaunchUsersController < Thredded::ApplicationController

    def index
      @relaunch_users = RelaunchUser.all
      render json: RelaunchUserSerializer.new(@relaunch_users).serializable_hash.to_json, status: 200
    end

    def create
      @relaunch_user = RelaunchUser.new(relaunch_user_params)

      if @relaunch_user.save
        render json: RelaunchUserSerializer.new(@relaunch_user).serializable_hash.to_json, status: 201
      else
        render json: { errors: @relaunch_user.errors }, status: 422
      end
    end

    def destroy
      relaunch_user.destroy!
      head 204
    end

    private

    def relaunch_user_params
      params
          .require(:relaunch_user)
          .permit(:email, :username)
    end

    def relaunch_user
      @relaunch_user ||= Thredded::RelaunchUser.find!(params[:id])
    end

  end
end
