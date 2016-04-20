# frozen_string_literal: true
module Thredded
  class ApplicationController < ::ApplicationController
    layout :thredded_layout
    include ::Thredded::UrlsHelper
    include Pundit

    helper Thredded::Engine.helpers
    helper_method \
      :active_users,
      :thredded_current_user,
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

    rescue_from Pundit::NotAuthorizedError,
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

    def thredded_current_user
      send(Thredded.current_user_method) || NullUser.new
    end

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

    def thredded_layout
      Thredded.layout
    end

    def unread_private_topics_count
      @unread_private_topics_count ||=
        if signed_in?
          Thredded::PrivateTopic
            .for_user(thredded_current_user)
            .unread(thredded_current_user)
            .count
        else
          0
        end
    end

    def authorize_reading(obj)
      return if policy(obj).read?

      class_name = obj.class.to_s
      error      = class_name.gsub(/Thredded::/, 'Thredded::Errors::') + 'ReadDenied'

      fail error.constantize
    end

    def authorize_creating(obj)
      return if policy(obj).create?

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

    def pundit_user
      thredded_current_user
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
