# frozen_string_literal: true

module Thredded
  class LikesController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[create destroy]
    before_action :find_topic, only: [:create, :destroy]
    before_action :find_like, only: [:destroy]
    after_action :verify_authorized, only: [:destroy]

    def create
      if already_liked?
        render json: { errors: "Das Topic wurde bereits geliked!" }, status: 400
      else
        @like = Like.new(user: thredded_current_user, topic: @topic)
        if @like.save
          render :json => {status: 201}
        else
          render json: { errors: @like.errors }, status: 422
        end
      end
    end

    def destroy
      if !(already_liked?)
        render json: { errors: "Das Topic wurde noch nicht geliked!" }, status: 400
      else
        @like.destroy!
        head 204
      end
    end

    private
    def find_like
      @like ||= Thredded::Like.find!(params[:id])
    end

    def find_topic
      @topic ||= Thredded::Topic.friendly_find!(params[:topic_id])
    end

    def already_liked?
      Like.where(user_id: thredded_current_user.id, topic_id: params[:topic_id]).exists?
    end

  end
end
