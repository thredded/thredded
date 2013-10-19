module Thredded
  class ApplicationController < ::ApplicationController
    helper Thredded::Engine.helpers
    helper_method :messageboard, :topic, :preferences
    before_filter :update_user_activity

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_path, alert: exception.message
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
      if params.key? :messageboard_id
        @messageboard ||= Messageboard.where(slug: params[:messageboard_id]).first
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
