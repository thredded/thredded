# frozen_string_literal: true
Rails.application.config.to_prepare do
  RailsEmailPreview.setup do |config|
    config.layout            = 'application'
    config.preview_classes   = Thredded::BaseMailerPreview.preview_classes
    # Do not show Send Email button
    config.enable_send_email = false
  end
end
