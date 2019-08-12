# frozen_string_literal: true

require 'html_pipeline_twemoji'

Thredded.user_class = 'User'
Thredded.user_name_column = :name
Thredded.user_path = ->(user) { main_app.user_path(user.id) }
Thredded.current_user_method = :"the_current_#{Thredded.user_class_name.underscore}"
Thredded.email_from = 'no-reply@example.com'
Thredded.email_outgoing_prefix = '[Thredded] '
Thredded.layout = 'application' unless ENV['THREDDED_DUMMY_LAYOUT_STANDALONE']
Thredded.avatar_url = ->(user) { Gravatar.src(user.email, 156, 'retro') }
Thredded.moderator_column = :admin
Thredded.admin_column = :admin
Thredded.content_visible_while_pending_moderation = true
Thredded.show_messageboard_delete_button = false
Thredded.parent_mailer = 'ApplicationMailer'
Thredded::ContentFormatter.after_markup_filters.insert(1, HTMLPipelineTwemoji)

Rails.application.config.to_prepare do
  # Thredded.notifiers = [Thredded::EmailNotifier.new]

  # try out with multiple notifiers:
  # require_dependency File.expand_path('../../../../support/mock_notifier', __FILE__)
  # Thredded.notifiers = [Thredded::EmailNotifier.new, MockNotifier.new]

  Thredded::ApplicationController.module_eval do
    include SetLocale
    rescue_from Thredded::Errors::LoginRequired do |exception|
      @message = exception.message
      render template: 'sessions/new', status: :forbidden
    end

    Thredded.view_hooks.post_form.content_text_area.config.after do
      # This is render in the Thredded view context, so all Thredded helpers and URLs are accessible here directly.
      content_tag :span, I18n.with_locale('en') { t('thredded_post_form_help_html') }, class: 'app-form-hint'
    end
  end
end
