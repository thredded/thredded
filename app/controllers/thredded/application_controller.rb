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
      :thredded_signed_in?

    rescue_from Thredded::Errors::MessageboardNotFound,
                Thredded::Errors::PrivateTopicNotFound,
                Thredded::Errors::TopicNotFound,
                Thredded::Errors::UserNotFound do |exception|
      @error   = exception
      @message = exception.message
      render template: 'thredded/error_pages/not_found', status: :not_found, formats: [:html]
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

    if Rails::VERSION::MAJOR < 5
      # redirect_back polyfill
      def redirect_back(fallback_location:, **args)
        redirect_to :back, args
      rescue ActionController::RedirectBackError
        redirect_to fallback_location, args
      end
    end

    # @param given [Hash]
    # @return [Boolean] whether the given params are a subset of the controller's {#params}.
    def params_match?(given = {})
      given.all? { |k, v| v == params[k] }
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
      @messageboard ||= Messageboard.friendly_find!(params[:messageboard_id])
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
