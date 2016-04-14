# frozen_string_literal: true
module Thredded
  class ApplicationController < ::ApplicationController
    layout Thredded.layout
    include ::Thredded::UrlsHelper

    helper Thredded::Engine.helpers
    helper_method \
      :active_users,
      :messageboard,
      :messageboard_or_nil,
      :preferences,
      :unread_private_topics_count,
      :signed_in?

    rescue_from Thredded::Errors::MessageboardNotFound,
                Thredded::Errors::PrivateTopicNotFound,
                Thredded::Errors::TopicNotFound,
                Thredded::Errors::UserNotFound do |exception|
      @error   = exception
      @message = exception.message
      render template: 'thredded/error_pages/not_found', status: :not_found
    end

    rescue_from CanCan::AccessDenied,
                Thredded::Errors::LoginRequired,
                Thredded::Errors::TopicCreateDenied,
                Thredded::Errors::MessageboardCreateDenied,
                Thredded::Errors::PrivateTopicCreateDenied,
                Thredded::Errors::MessageboardReadDenied do |exception|
      @error   = exception
      @message = exception.message
      render template: 'thredded/error_pages/forbidden', status: :forbidden
    end

    protected

    def signed_in?
      !thredded_current_user.thredded_anonymous?
    end

    if Rails::VERSION::MAJOR < 5
      # redirect_back polyfill
      def redirect_back(fallback_location:, **args)
        redirect_to :back, args
      rescue ActionController::RedirectBackError
        redirect_to fallback_location, args
      end
    end

    private

    def unread_private_topics_count
      @unread_private_topics_count ||=
        Thredded::PrivateTopic
          .joins(:private_users)
          .where(
            thredded_private_users: {
              user_id: thredded_current_user.id,
              read:    false
            })
          .count
    end

    def authorize_reading(obj)
      return if current_ability.can? :read, obj

      class_name = obj.class.to_s
      error      = class_name.gsub(/Thredded::/, 'Thredded::Errors::') + 'ReadDenied'

      fail error.constantize
    end

    def authorize_creating(obj)
      obj = obj.new if obj.class == Class

      return if current_ability.can? :create, obj

      class_name = obj.class.to_s
      error      = class_name.gsub(/Thredded::/, 'Thredded::Errors::') + 'CreateDenied'

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
      @messageboard ||= params[:messageboard_id].presence && Messageboard.friendly.find(params[:messageboard_id])
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::MessageboardNotFound
    end

    def messageboard_or_nil
      messageboard
    rescue Thredded::Errors::MessageboardNotFound
      nil
    end

    def preferences
      @preferences ||= thredded_current_user.thredded_user_preference
    end

    def thredded_current_user
      current_user || NullUser.new
    end

    def active_users
      users = if messageboard_or_nil
                messageboard.recently_active_users
              else
                Thredded.user_class.joins(:thredded_user_detail).merge(Thredded::UserDetail.recently_active).to_a
              end.to_a
      users.push(thredded_current_user) unless thredded_current_user.is_a?(NullUser)
      users.uniq
    end

    def thredded_require_login!
      fail Thredded::Errors::LoginRequired if thredded_current_user.thredded_anonymous?
    end
  end
end
