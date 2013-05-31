module Thredded
  class SetupsController < ApplicationController
    def new
      @messageboard = Messageboard.new
    end

    def create
      messageboard_params = params[:messageboard].merge!({theme: 'default'})
      @messageboard = Messageboard.create(messageboard_params)

      if @messageboard.valid?
        current_user.admin_of @messageboard
        @messageboard.topics.create(topic_params)

        sign_in @user
        redirect_to root_path
      end
    end

    private

    def topic_params
      {
        user: current_user,
        last_user: current_user,
        title: "Welcome to your messageboard's very first thread",
        posts_attributes: {
          '0' => {
            content: "There's not a whole lot here for now.",
            user: current_user,
            ip: '127.0.0.1',
            messageboard: @messageboard
          }
        }
      }
    end
  end
end
