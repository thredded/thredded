# frozen_string_literal: true

module Thredded
  class ApplicationController < ::ApplicationController # rubocop:disable Metrics/ClassLength
    layout :thredded_layout
    include ::Thredded::UrlsHelper
    include Pundit

    helper Thredded::Engine.helpers
    helper_method \
      :active_users,
      :thredded_current_user,
      :messageboard,
      :messageboard_or_nil,
      :unread_private_topics_count,
      :unread_followed_topics_count,
      :unread_topics_count,
      :preferences,
      :thredded_signed_in?,
      :thredded_moderator?

    rescue_from Thredded::Errors::MessageboardNotFound,
                Thredded::Errors::PrivateTopicNotFound,
                Thredded::Errors::PrivatePostNotFound,
                Thredded::Errors::TopicNotFound,
                Thredded::Errors::PostNotFound,
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
      @message = if @error.is_a?(Pundit::NotAuthorizedError)
                   t('thredded.errors.not_authorized')
                 else
                   exception.message
                 end
      render template: 'thredded/error_pages/forbidden', status: :forbidden
    end

    protected

    # The `current_user` and `signed_in?` methods are prefixed with `thredded_`
    # to avoid conflicts with methods from the parent controller.

    def thredded_current_user
      send(Thredded.current_user_method) || NullUser.new
    end

    def thredded_signed_in?
      !thredded_current_user.thredded_anonymous?
    end

    def thredded_moderator?
      return @is_thredded_moderator unless @is_thredded_moderator.nil?
      @is_thredded_moderator = !thredded_current_user.thredded_can_moderate_messageboards.empty?
    end

    # @param given [Hash]
    # @return [Boolean] whether the given params are a subset of the controller's {#params}.
    def params_match?(given = {})
      given.all? { |k, v| v == params[k] }
    end

    # Returns true if the current page is beyond the end of the collection
    def page_beyond_last?(page_scope)
      page_scope.to_a.empty? && page_scope.current_page != 1
    end

    # Returns URL parameters for the last page of the given page scope.
    def last_page_params(page_scope)
      { page: page_scope.total_pages }
    end

    private

    def thredded_layout
      Thredded.layout
    end

    def authorize_reading(obj)
      authorize obj, :read?
    rescue Pundit::NotAuthorizedError
      raise "#{obj.class.to_s.sub(/Thredded::/, 'Thredded::Errors::')}ReadDenied".constantize
    end

    def authorize_creating(obj)
      authorize obj, :create?
    rescue Pundit::NotAuthorizedError
      raise "#{obj.class.to_s.sub(/Thredded::/, 'Thredded::Errors::')}CreateDenied".constantize
    end

    def update_user_activity
      return if !messageboard_or_nil || !thredded_signed_in?

      Thredded::ActivityUpdaterJob.perform_later(
        thredded_current_user.id,
        messageboard.id
      )
    end

    def pundit_user
      thredded_current_user
    end

    # Returns the `@messageboard` instance variable.
    # If `@messageboard` is not set, it first sets it to the messageboard with the slug or ID given by
    # `params[:messageboard_id]`.
    #
    # @return [Thredded::Messageboard]
    # @raise [Thredded::Errors::MessageboardNotFound] if the messageboard with the given slug does not exist.
    def messageboard
      @messageboard ||= Thredded::Messageboard.friendly_find!(params[:messageboard_id])
    end

    def messageboard_or_nil
      messageboard
    rescue Thredded::Errors::MessageboardNotFound
      nil
    end

    # @return [ActiveRecord::Relation]
    def topics_scope
      @topics_scope ||=
        if messageboard_or_nil
          policy_scope(messageboard.topics)
        else
          policy_scope(Thredded::Topic.all).joins(:messageboard).merge(policy_scope(Thredded::Messageboard.all))
        end
    end

    def unread_private_topics_count
      @unread_private_topics_count ||=
        if thredded_signed_in?
          Thredded::PrivateTopic
            .for_user(thredded_current_user)
            .unread(thredded_current_user)
            .count
        else
          0
        end
    end

    def unread_followed_topics_count
      @unread_followed_topics_count ||=
        if thredded_signed_in?
          topics_scope.unread_followed_by(thredded_current_user).count
        else
          0
        end
    end

    def unread_topics_count
      @unread_topics_count ||=
        if thredded_signed_in?
          topics_scope.unread(thredded_current_user).count
        else
          0
        end
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

    def thredded_require_moderator!
      return if thredded_moderator?
      fail Pundit::NotAuthorizedError, 'You are not authorized to perform this action.'
    end
  end
end
