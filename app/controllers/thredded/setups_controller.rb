module Thredded
  class SetupsController < ApplicationController
    def new
      @messageboard = Messageboard.new
    end

    def create
      messageboard_params = params[:messageboard]
      @messageboard = Messageboard.create(messageboard_params)

      if @messageboard.valid?
        @messageboard.add_member(current_user, 'admin')
        @messageboard.topics.create(topic_params)

        redirect_to root_path
      else
        render action: :new
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
