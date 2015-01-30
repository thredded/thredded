module Thredded
  class ApplicationController < ::ApplicationController
    layout Thredded.layout

    helper Thredded::Engine.helpers
    helper_method \
      :active_users,
      :messageboard,
      :preferences,
      :unread_private_topics_count

    rescue_from \
      CanCan::AccessDenied,
      Thredded::Errors::MessageboardNotFound,
      Thredded::Errors::MessageboardReadDenied,
      Thredded::Errors::TopicCreateDenied,
      Thredded::Errors::MessageboardCreateDenied,
      Thredded::Errors::PrivateTopicCreateDenied do |exception|
      redirect_to thredded.root_path, alert: exception.message
    end

    rescue_from \
      Thredded::Errors::EmptySearchResults,
      Thredded::Errors::TopicNotFound do |exception|
      redirect_to messageboard_topics_path(messageboard), alert: exception.message
    end

    def signed_in?
      !current_user.anonymous?
    end

    private

    def unread_private_topics_count
      Rails.cache.fetch("private_topics_count_#{messageboard.id}_#{current_user.id}") do
        Thredded::PrivateTopic
          .joins(:private_users)
          .where(
            messageboard: messageboard,
            thredded_private_users: {
              user_id: current_user.id,
              read: false,
            }
          )
          .count
      end
    end

    def authorize_reading(obj)
      return if can? :read, obj

      class_name = obj.class.to_s
      error = class_name
        .gsub(/Thredded::/, 'Thredded::Errors::') + 'ReadDenied'

      fail error.constantize
    end

    def authorize_creating(obj)
      obj = obj.new if obj.class == Class

      return if can? :create, obj

      class_name = obj.class.to_s
      error = class_name
        .gsub(/Thredded::/, 'Thredded::Errors::') + 'CreateDenied'

      fail error.constantize
    end

    def update_user_activity
      Thredded::ActivityUpdaterJob.queue.update_user_activity(
        'messageboard_id' => messageboard.id,
        'user_id' => current_user.id
      )
    end

    def current_ability
      @current_ability ||= Ability.new(current_user)
    end

    def messageboard
      @messageboard ||= Messageboard.find_by_slug(params[:messageboard_id])
    end

    def preferences
      @preferences ||= current_user.thredded_user_preference
    end

    def current_user
      super || NullUser.new
    end

    def active_users
      users = messageboard.try(:active_users) || []
      users.push(current_user) unless current_user.is_a?(NullUser)
      users.uniq
    end
  end
end
