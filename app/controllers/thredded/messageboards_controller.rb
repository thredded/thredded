# frozen_string_literal: true

module Thredded
  class MessageboardsController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[new create update destroy]
    skip_before_action :verify_authenticity_token

    after_action :verify_authorized, except: %i[index show]
    after_action :verify_policy_scoped, except: %i[new create update destroy show]

    def index
      @groups = Thredded::MessageboardGroupView.grouped(
        policy_scope(Thredded::Messageboard.all),
        user: thredded_current_user
      )
      #render json: MessageboardgroupviewSerializer.new(@groups).serialized_json, status: 200
    end

    def show
      begin
        @messageboard = Thredded::Messageboard.friendly_find!(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: @messageboard.errors, status: 404
        return
      rescue Exception
        raise
      end
      render json: MessageboardSerializer.new(@messageboard).serialized_json, status: 200
    end

    def new
      @new_messageboard = Thredded::Messageboard.new
      authorize_creating @new_messageboard
    end

    def create
      @new_messageboard = Thredded::Messageboard.new(messageboard_params)
      authorize_creating @new_messageboard
      if Thredded::CreateMessageboard.new(@new_messageboard, thredded_current_user).run
        render json: MessageboardSerializer.new(@new_messageboard).serialized_json, status: 201
      else
        render json: @new_messageboard.errors, status: 422
      end
    end

    def update
      @messageboard = Thredded::Messageboard.friendly_find!(params[:id])
      authorize @messageboard, :update?
      if @messageboard.update(messageboard_params)
        render json: MessageboardSerializer.new(@messageboard).serialized_json, status: 200
      else
        render json: @messageboard.errors, status: 422
      end
    end

    def destroy
      begin
        @messageboard = Thredded::Messageboard.friendly_find!(params[:id])
        authorize @messageboard, :destroy?
        @messageboard.destroy!
      rescue ActiveRecord::RecordNotFound
        render json: @messageboard.errors, status: 404
        return
      rescue ActiveRecord::InvalidForeignKey
        render json: @messageboard.errors, status: 403
        return
      rescue Exception
        raise
      end
      render json: :no_content, status: 204
    end

    private

    def messageboard_params
      params
        .require(:messageboard)
        .permit(:name, :description, :messageboard_group_id, :locked)
    end
  end
end
