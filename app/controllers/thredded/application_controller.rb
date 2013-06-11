module Thredded
  class ApplicationController < ::ApplicationController
    helper Thredded::Engine.helpers
    helper_method :messageboard, :topic, :preferences

    rescue_from CanCan::AccessDenied do |exception|
      flash[:error] = exception.message
      redirect_to root_path
    end

    private

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end

    def messageboard
      if params.key? :messageboard_id
        @messageboard ||= Messageboard.find(params[:messageboard_id])
      end
    end

    def preferences
      if current_user
        @preferences ||= UserPreference.where(user_id: current_user.id).first
      end
    end

    def topic
      if messageboard
        @topic ||= messageboard.topics.find(params[:topic_id])
      end
    end

    def ensure_messageboard_exists
      if messageboard.blank?
        redirect_to thredded.root_path,
          flash: { error: 'This messageboard does not exist.' }
      end
    end
  end
end
