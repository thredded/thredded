# frozen_string_literal: true

module Thredded
  class MessageboardGroupsController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[create update destroy]
    after_action :verify_authorized, except: %i[index show]

    def create
      @messageboard_group = Thredded::MessageboardGroup.new(messageboard_group_params)
      authorize @messageboard_group, :create?
      if @messageboard_group.save
        render json: MessageboardGroupSerializer.new(@messageboard_group).serializable_hash.to_json, status: 201
      else
        render json: { errors: @messageboard_group.errors }, status: 422
      end
    end

    def show
      @group = Thredded::MessageboardGroup.find!(params[:id])
      render json: MessageboardGroupSerializer.new(@group,
                                                   include: %i[messageboards messageboards.last_user messageboards.last_topic])
        .serializable_hash.to_json, status: 200
    end

    def index
      @groups = Thredded::MessageboardGroup.ordered.all
      render json: MessageboardGroupSerializer.new(@groups,
                                                   include: %i[messageboards messageboards.last_user messageboards.last_topic])
        .serializable_hash.to_json, status: 200
    end

    def update
      @group = Thredded::MessageboardGroup.find!(params[:id])
      authorize @group, :update?
      if @group.update(messageboard_group_params)
        render json: MessageboardGroupSerializer.new(@group,
                                                     include: %i[messageboards messageboards.last_user messageboards.last_topic])
          .serializable_hash.to_json, status: 200
      else
        render json: { errors: @group.errors }, status: 422
      end
    end

    def destroy
      @group = Thredded::MessageboardGroup.find!(params[:id])
      authorize @group, :destroy?
      @group.destroy!
      head 204
    end

    private

    def messageboard_group_params
      params
        .require(:messageboard_group)
        .permit(:name)
    end
  end
end
