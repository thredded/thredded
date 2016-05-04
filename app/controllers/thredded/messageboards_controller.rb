# frozen_string_literal: true
module Thredded
  class MessageboardsController < Thredded::ApplicationController
    def index
      @groups = thredded_current_user
        .thredded_can_read_messageboards
        .preload(:group).group_by(&:group)
        .map { |(group, messageboards)| MessageboardGroupView.new(group, messageboards) }
    end

    def new
      @messageboard = Messageboard.new
      @messageboard_group = MessageboardGroup.all
      authorize_creating @messageboard
    end

    def create
      @messageboard = Messageboard.new(messageboard_params)
      authorize_creating @messageboard

      if signed_in? && @messageboard.save
        Topic.transaction do
          @topic = Topic.create!(topic_params)
          @post = Post.create!(post_params)
        end

        redirect_to root_path
      else
        show_sign_in_error unless signed_in?
        render action: :new
      end
    end

    private

    def show_sign_in_error
      flash.now[:error] = 'You are not signed in. Sign in or create an account before creating your messageboard.'
    end

    def messageboard_params
      params
        .require(:messageboard)
        .permit(:description, :name, :posting_permission, :security, :messageboard_group_id)
    end

    def topic_params
      {
        messageboard: @messageboard,
        user: thredded_current_user,
        last_user: thredded_current_user,
        title: "Welcome to your messageboard's very first thread",
      }
    end

    def post_params
      {
        messageboard: @messageboard,
        postable: @topic,
        content: "There's not a whole lot here for now.",
        ip: request.ip,
        user: thredded_current_user,
      }
    end
  end
end
