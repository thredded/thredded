module Thredded
  class ApplicationController < ::ApplicationController
    helper Thredded::Engine.helpers
    helper_method :messageboard, :preferences
    layout Thredded.layout

    rescue_from CanCan::AccessDenied,
      Thredded::Errors::MessageboardNotFound,
      Thredded::Errors::MessageboardReadDenied,
      Thredded::Errors::TopicCreateDenied do |exception|

      redirect_to thredded.root_path, alert: exception.message
    end

    rescue_from Thredded::Errors::EmptySearchResults,
      Thredded::Errors::TopicNotFound do |exception|

      redirect_to messageboard_topics_path(messageboard),
        alert: exception.message
    end

    private

    def authorize_reading(obj)
      if cannot? :read, obj
        class_name = obj.class.to_s
        error = class_name
          .gsub(/Thredded::/, 'Thredded::Errors::') + 'ReadDenied'
        raise error.constantize
      end
    end

    def authorize_creating(obj)
      if cannot? :create, obj
        class_name = obj.class.to_s
        error = class_name
          .gsub(/Thredded::/, 'Thredded::Errors::') + 'CreateDenied'
        raise error.constantize
      end
    end

    def update_user_activity
      messageboard.update_activity_for!(current_user)
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
  end
end
