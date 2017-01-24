# frozen_string_literal: true
module Thredded
  class PrivateTopicMailer < Thredded::BaseMailer
    def message_notification(private_topic_id, post, emails)
      @topic               = find_record Thredded::PrivateTopic, private_topic_id
      @post                = post
      email_details        = Thredded::TopicEmailView.new(@topic)
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('private_topic_mailer')

      mail from:     email_details.no_reply,
           to:       email_details.no_reply,
           bcc:      emails,
           subject:  email_details.subject
    end
  end
end
