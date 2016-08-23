# frozen_string_literal: true
require_dependency 'thredded/topic_email_view'
module Thredded
  class TopicMailer < Thredded::BaseMailer
    def topic_created(topic_id)
      @topic                = find_record Topic, topic_id
      email_details        = TopicEmailView.new(@topic)
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('post_notification')

      mail from:     email_details.no_reply,
           to:       email_details.no_reply,
           reply_to: email_details.reply_to,
           subject:  email_details.subject
    end
  end
end
