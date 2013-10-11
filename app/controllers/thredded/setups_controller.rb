module Thredded
  class SetupsController < Thredded::ApplicationController
    def new
      @messageboard = Messageboard.new
    end

    def create
      @messageboard = Messageboard.create(messageboard_params)

      if @messageboard.valid?
        @messageboard.update_attribute(:slug, @messageboard.name)  #not sure if we want to do this here, or set that as a hidden field on submit of the form, or add to the messageboard params before create... i'm open -RUSS
        @messageboard.add_member(current_user, 'admin')
        @messageboard.topics.create(topic_params)

        redirect_to root_path
      else
        render action: :new
      end
    end

    private

    def messageboard_params
      params
        .require(:messageboard)
        .permit(:description, :name, :posting_permission, :security)
    end

    def topic_params
      {
        user: current_user,
        last_user: current_user,
        title: "Welcome to your messageboard's very first thread",
        posts_attributes: {
          '0' => {
            content: "There's not a whole lot here for now.",
            ip: '127.0.0.1',
            messageboard: @messageboard,
            user: current_user,
          }
        }
      }
    end
  end
end
