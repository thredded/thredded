module Thredded
  class ApplicationController < ::ApplicationController
    helper Thredded::Engine.helpers
    helper_method :messageboard, :topic, :preferences

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to thredded.root_path, alert: exception.message
    end

    rescue_from Thredded::Errors::MessageboardNotFound do |exception|
      redirect_to thredded.root_path, alert: exception.message
    end

    private

    def update_user_activity
      if messageboard && current_user
        messageboard.update_activity_for!(current_user)
      end
    end

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end

    def messageboard
      @messageboard ||= Messageboard.find_by_slug(params[:messageboard_id])
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
  end
end
