module Thredded
  class PrivatePostMailer < Thredded::BaseMailer
    def at_notification(post_id, emails)
      @post                = find_record PrivatePost, post_id
      email_details        = TopicEmailDecorator.new(@post.postable)
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('at_notification')

      mail from:     email_details.no_reply,
           to:       email_details.no_reply,
           bcc:      emails,
           reply_to: email_details.reply_to,
           subject:  email_details.subject
    end
  end
end
