module Thredded
  class PostMailer < Thredded::BaseMailer
    def at_notification(post_id, user_emails)
      @post = Post.find(post_id)

      headers['X-SMTPAPI'] = %Q{{"category": ["thredded_#{@post.messageboard.name}","at_notification"]}}
      mail from: no_reply,
        to: no_reply,
        bcc: user_emails,
        reply_to: reply_to,
        subject: subject
    end

    private

    def subject
      "#{Thredded.email_outgoing_prefix} #{@post.topic.title}"
    end

    def reply_to
      "#{@post.topic.hash_id}@#{Thredded.email_incoming_host}"
    end

    def no_reply
      Thredded.email_from
    end
  end
end
