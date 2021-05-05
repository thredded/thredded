# frozen_string_literal: true

module Thredded
  class LikesController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[create destroy]
    before_action :find_topic, only: [:create, :destroy]
    before_action :find_like, only: [:destroy]
    after_action :verify_authorized, only: [:destroy]
    after_action :update_received_likes_user

    def create
      @like = Like.new(user: thredded_current_user, topic: @topic)
      if @like.save
        head 204
      else
        render json: { errors: @like.errors }, status: 422
      end
    end

    def destroy
      authorize @like, :destroy?
      @like.destroy!
      head 204
    end

    private
    def find_like
      @like ||= Like.find!(thredded_current_user.id, params[:topic_id])
    end

    def find_topic
      @topic ||= Thredded::Topic.friendly_find!(params[:topic_id])
    end

    def update_received_likes_user
      Thredded::MovieLikesUserUpdaterJob.perform_later(
          @topic.user_id
      )
    end
  end
end
