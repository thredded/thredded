# frozen_string_literal: true
require_dependency 'thredded/topic_email_view'
module Thredded
  class PostMailer < Thredded::BaseMailer
    def post_notification(post_id, emails)
      @post                = find_record Post, post_id
      email_details        = TopicEmailView.new(@post.postable)
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('post_notification')

      mail from:     email_details.no_reply,
           to:       email_details.no_reply,
           bcc:      emails,
           reply_to: email_details.reply_to,
           subject:  email_details.subject
    end
  end
end
