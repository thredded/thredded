# frozen_string_literal: true
Thredded.user_class = 'User'
Thredded.user_name_column = :name
Thredded.user_path = ->(user) { main_app.user_path(user.id) }
Thredded.current_user_method = :"the_current_#{Thredded.user_class.name.underscore}"
Thredded.email_incoming_host = 'incoming.example.com'
Thredded.email_from = 'no-reply@example.com'
Thredded.email_outgoing_prefix = '[Thredded] '
Thredded.layout = 'application' unless ENV['THREDDED_DUMMY_LAYOUT_STANDALONE']
Thredded.avatar_url = ->(user) { Gravatar.src(user.email, 128, 'retro') }
Thredded.moderator_column = :admin
Thredded.admin_column = :admin
Thredded.content_visible_while_pending_moderation = true

Rails.application.config.to_prepare do
  Thredded::ApplicationController.module_eval do
    include SetLocale
    rescue_from Thredded::Errors::LoginRequired do |exception|
      @message = exception.message
      render template: 'sessions/new', status: :forbidden
    end
  end
end
