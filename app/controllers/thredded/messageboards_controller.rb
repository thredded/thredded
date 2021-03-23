# frozen_string_literal: true

module Thredded
  class MessageboardsController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[create update destroy]

    after_action :verify_authorized, except: %i[index show]
    after_action :verify_policy_scoped, except: %i[create update destroy show]

    def index
      @groups = Thredded::MessageboardGroupView.grouped(
        policy_scope(Thredded::Messageboard.all),
        user: thredded_current_user
      )
      render json: MessageboardGroupViewSerializer.new(@groups,
                                                       include: %i[messageboards group messageboards.messageboard])
        .serializable_hash.to_json, status: 200
    end

    def show
      @messageboard = Thredded::Messageboard.friendly_find!(params[:id])
      render json: MessageboardSerializer.new(@messageboard).serializable_hash.to_json, status: 200
    end

    def create
      @new_messageboard = Thredded::Messageboard.new(new_messageboard_params)
      Thredded::Badge.find!(@new_messageboard.badge_id)
      authorize_creating @new_messageboard
      MessageboardGroup.find!(new_messageboard_params[:messageboard_group_id]) if new_messageboard_params[:messageboard_group_id].present?
      begin
        if Thredded::CreateMessageboard.new(@new_messageboard, thredded_current_user).run
          render json: MessageboardSerializer.new(@new_messageboard).serializable_hash.to_json, status: 201
        else
          render json: { errors: @new_messageboard.errors }, status: 422
        end
      rescue ActiveRecord::SubclassNotFound
        raise Thredded::Errors::TopicSubclassNotFound
      end
    end

    def update
      @messageboard = Thredded::Messageboard.friendly_find!(params[:id])
      authorize @messageboard, :update?
      if Thredded::Badge.find!(messageboard_params[:badge_id]) && @messageboard.update(messageboard_params)
        render json: MessageboardSerializer.new(@messageboard).serializable_hash.to_json, status: 200
      else
        render json: { error: @messageboard.errors }, status: 422
      end
    end

    def destroy
      @messageboard = Thredded::Messageboard.friendly_find!(params[:id])
      authorize @messageboard, :destroy?
      @messageboard.destroy!
      head 204
    end

    private

    def messageboard_params
      params
        .require(:messageboard)
        .permit(:name, :description, :messageboard_group_id, :badge_id, :locked)
    end

    def new_messageboard_params
      params
        .require(:messageboard)
        .permit(:name, :description, :messageboard_group_id, :locked, :badge_id, topic_types: [])
    end
  end
end
