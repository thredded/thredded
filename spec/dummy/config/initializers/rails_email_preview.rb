# frozen_string_literal: true
Rails.application.config.to_prepare do
  RailsEmailPreview.setup do |config|
    config.before_render do |message, _preview_class_name, _mailer_action|
      Roadie::Rails::MailInliner.new(message, message.roadie_options).execute
    end
    config.layout            = 'application'
    config.preview_classes   = Thredded::BaseMailerPreview.preview_classes
    # Do not show Send Email button
    config.enable_send_email = false
  end
end
