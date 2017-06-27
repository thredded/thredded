# frozen_string_literal: true

module Thredded
  class MessageboardsController < Thredded::ApplicationController
    before_action :thredded_require_login!, only: %i[new create edit update]

    after_action :verify_authorized, except: %i[index]
    after_action :verify_policy_scoped, except: %i[new create edit update]

    def index
      @groups = Thredded::MessageboardGroupView.grouped(policy_scope(Thredded::Messageboard.all))
    end

    def new
      @messageboard = Thredded::Messageboard.new
      @messageboard_group = Thredded::MessageboardGroup.all
      authorize_creating @messageboard
    end

    def create
      @messageboard = Thredded::Messageboard.new(messageboard_params)
      authorize_creating @messageboard
      if Thredded::CreateMessageboard.new(@messageboard, thredded_current_user).run
        redirect_to root_path
      else
        render :new
      end
    end

    def edit
      @messageboard = Thredded::Messageboard.friendly_find!(params[:id])
      authorize @messageboard, :update?
    end

    def update
      @messageboard = Thredded::Messageboard.friendly_find!(params[:id])
      authorize @messageboard, :update?
      if @messageboard.update(messageboard_params)
        redirect_to messageboard_topics_path(@messageboard), notice: I18n.t('thredded.messageboard.updated_notice')
      else
        render :edit
      end
    end

    private

    def messageboard_params
      params
        .require(:messageboard)
        .permit(:name, :description, :messageboard_group_id)
    end
  end
end
