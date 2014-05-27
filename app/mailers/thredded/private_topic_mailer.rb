module Thredded
  class PrivateTopicMailer < Thredded::BaseMailer
    def message_notification(private_topic_id, emails)
      @private_topic = PrivateTopic.find(private_topic_id)
      headers['X-SMTPAPI'] =
        %Q{{"category": ["thredded_#{@private_topic.messageboard.name}","private_topic_mailer"]}}

      mail from: no_reply,
        to: no_reply,
        bcc: emails,
        reply_to: reply_to,
        subject: subject
    end

    private

    def subject
      "#{Thredded.email_outgoing_prefix} #{@private_topic.title}"
    end

    def reply_to
      "#{@private_topic.hash_id}@#{Thredded.email_incoming_host}"
    end

    def no_reply
      Thredded.email_from
    end
  end
end
