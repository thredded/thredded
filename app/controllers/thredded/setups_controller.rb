module Thredded
  class SetupsController < Thredded::ApplicationController
    def new
      @messageboard = Messageboard.new
    end

    def create
      @messageboard = Messageboard.new(messageboard_params)

      if @messageboard.valid? && @messageboard.save
        @topic = Topic.create(topic_params)
        @post = Post.create(post_params)
        @messageboard.add_member(current_user, 'admin')

        redirect_to root_path
      else
        render action: :new
      end
    end

    private

    def messageboard_params
      params
        .require(:messageboard)
        .permit(:description, :name, :posting_permissions, :security)
    end

    def topic_params
      {
        messageboard: @messageboard,
        user: current_user,
        last_user: current_user,
        title: "Welcome to your messageboard's very first thread",
      }
    end

    def post_params
      {
        messageboard: @messageboard,
        topic: @topic,
        content: "There's not a whole lot here for now.",
        ip: request.ip,
        user: current_user,
      }
    end
  end
end
