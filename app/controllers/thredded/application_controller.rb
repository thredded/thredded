module Thredded
  class ApplicationController < ::ApplicationController
    layout Thredded.layout

    helper Thredded::Engine.helpers
    helper_method \
      :active_users,
      :messageboard,
      :preferences,
      :unread_private_topics_count,
      :signed_in?

    rescue_from \
      CanCan::AccessDenied,
      Thredded::Errors::MessageboardNotFound,
      Thredded::Errors::MessageboardReadDenied,
      Thredded::Errors::TopicCreateDenied,
      Thredded::Errors::MessageboardCreateDenied,
      Thredded::Errors::PrivateTopicCreateDenied do |exception|
        redirect_to root_path,
          flash: { alert: exception.message }
      end

    rescue_from \
      Thredded::Errors::EmptySearchResults,
      Thredded::Errors::TopicNotFound do |exception|
        redirect_to messageboard_topics_path(messageboard),
          flash: { error: exception.message }
      end

    def signed_in?
      !thredded_current_user.thredded_anonymous?
    end

    private

    def unread_private_topics_count
      @unread_private_topics_count ||= Thredded::PrivateTopic
        .joins(:private_users)
        .where(
          thredded_private_users: {
            user_id: thredded_current_user.id,
            read: false
          })
        .count
    end

    def authorize_reading(obj)
      return if current_ability.can? :read, obj

      class_name = obj.class.to_s
      error = class_name
        .gsub(/Thredded::/, 'Thredded::Errors::') + 'ReadDenied'

      fail error.constantize
    end

    def authorize_creating(obj)
      obj = obj.new if obj.class == Class

      return if current_ability.can? :create, obj

      class_name = obj.class.to_s
      error = class_name
        .gsub(/Thredded::/, 'Thredded::Errors::') + 'CreateDenied'

      fail error.constantize
    end

    def update_user_activity
      return if messageboard.nil?

      Thredded::ActivityUpdaterJob.perform_later(
        thredded_current_user.id,
        messageboard.id
      )
    end

    def current_ability
      @current_ability ||= Ability.new(thredded_current_user)
    end

    def messageboard
      @messageboard ||= params[:messageboard_id].presence && Messageboard.find_by_slug!(params[:messageboard_id])
    end

    def preferences
      @preferences ||= thredded_current_user.thredded_user_preference
    end

    def thredded_current_user
      current_user || NullUser.new
    end

    def active_users
      users = if messageboard
                messageboard.recently_active_users
              else
                Thredded.user_class.joins(:thredded_user_detail).merge(Thredded::UserDetail.recently_active).to_a
              end.to_a
      users.push(thredded_current_user) unless thredded_current_user.is_a?(NullUser)
      users.uniq
    end
  end
end
