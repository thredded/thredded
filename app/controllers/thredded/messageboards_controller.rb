module Thredded
  class MessageboardsController < Thredded::ApplicationController
    def index
      @messageboards = Messageboard.where(closed: false).decorate
    end

    def new
      authorize_creating Messageboard

      @messageboard = Messageboard.new
    end

    def create
      @messageboard = Messageboard.new(messageboard_params)

      if signed_in? && @messageboard.valid? && @messageboard.save
        @topic = Topic.create(topic_params)
        @post = Post.create(post_params)
        @messageboard.add_member(current_user, 'admin')

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
        .permit(:description, :name, :posting_permission, :security)
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
        postable: @topic,
        content: "There's not a whole lot here for now.",
        ip: request.ip,
        user: current_user,
      }
    end
  end
end
