# frozen_string_literal: true

module Thredded
  class MessageboardGroupsController < Thredded::ApplicationController
    def new
      @messageboard_group = MessageboardGroup.new
      authorize @messageboard_group, :create?
    end

    def create
      @messageboard_group = MessageboardGroup.new(messageboard_group_params)
      authorize @messageboard_group, :create?

      if @messageboard_group.save
        redirect_to root_path, notice: I18n.t('thredded.messageboard_group.saved', name: @messageboard_group.name)
      else
        flash.now[:notice] = @messageboard_group.errors.full_messages.to_sentence

        render action: :new
      end
    end

    private

    def messageboard_group_params
      params
        .require(:messageboard_group)
        .permit(:name)
    end
  end
end
