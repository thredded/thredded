# frozen_string_literal: true

module Thredded
  class BadgesController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[create update destroy main]

    after_action :verify_authorized, except: %i[show index main]

    before_action :use_users, only: %i[assign remove]

    def index
      @badges = policy_scope(Badge)
      render json: BadgeSerializer.new(@badges).serializable_hash.to_json, status: 200
    end

    def show
      render json: BadgeSerializer.new(badge).serializable_hash.to_json, status: 200
    end

    def create
      @badge = Badge.new(badge_params)
      authorize_creating @badge

      if @badge.save
        render json: BadgeSerializer.new(@badge).serializable_hash.to_json, status: 201
      else
        render json: { errors: @badge.errors }, status: 422
      end
    end

    def update
      authorize badge, :update?
      if badge.update(badge_params)
        render json: BadgeSerializer.new(badge).serializable_hash.to_json, status: 200
      else
        render json: { errors: badge.errors }, status: 422
      end
    end

    def destroy
      authorize badge, :destroy?
      badge.destroy!
      head 204
    end

    def assign
      authorize badge, :update?
      if badge.update(users: badge.users |= use_users)
        render json: BadgeSerializer.new(badge).serializable_hash.to_json, status: 200
      else
        render json: { errors: badge.errors }, status: 422
      end
    end

    def remove
      authorize badge, :update?
      badge.users.delete(use_users)
      render json: BadgeSerializer.new(badge).serializable_hash.to_json, status: 200
    end

    def main
      if thredded_current_user.update(thredded_main_badge: badge)
        render json: BadgeSerializer.new(badge).serializable_hash.to_json, status: 200
      else
        render json: { errors: thredded_current_user.errors }, status: 422
      end
    end

    private

    def badge_params
      params
        .require(:badge)
        .permit(:title, :description, :badge_icon, :secret)
    end

    def use_users
      user_ids = params[:user_ids].split(',')
      @users = []
      user_ids.each do |user_id|
        @users |= [find_user(user_id)]
      end
      @users
    end

    def badge
      @badge ||= Thredded::Badge.find!(params[:id])
    end
  end
end
