# frozen_string_literal: true
module Thredded
  class PrivateTopicMailer < Thredded::BaseMailer
    def message_notification(private_topic_id, emails)
      @topic               = find_record PrivateTopic, private_topic_id
      email_details        = TopicEmailDecorator.new(@topic)
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('private_topic_mailer')

      mail from:     email_details.no_reply,
           to:       email_details.no_reply,
           bcc:      emails,
           reply_to: email_details.reply_to,
           subject:  email_details.subject
    end
  end
end
