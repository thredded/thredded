module Thredded
  class TopicMailer < Thredded::BaseMailer
    def message_notification(topic_id, emails)
      @topic = Topic.find(topic_id)
      headers['X-SMTPAPI'] =
        %Q{{"category": ["thredded_#{@topic.messageboard.name}","at_notification"]}}

      mail from: no_reply,
        to: no_reply,
        bcc: emails,
        reply_to: reply_to,
        subject: subject
    end

    private

    def subject
      "#{Thredded.email_outgoing_prefix} #{@topic.title}"
    end

    def reply_to
      "#{@topic.hash_id}@#{Thredded.email_incoming_host}"
    end

    def no_reply
      Thredded.email_from
    end
  end
end
