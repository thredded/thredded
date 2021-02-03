# frozen_string_literal: true

module Thredded
  class PostMailer < Thredded::BaseMailer
    def post_notification(post_id, emails)
      @post = find_record Thredded::Post, post_id
      email_details = Thredded::TopicEmailView.new(@post.postable)
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('post_notification')

      mail from: email_details.no_reply,
           to: email_details.no_reply,
           bcc: emails,
           subject: [
             Thredded.email_outgoing_prefix,
             t('Ein neuer Post in: ',
               user: @post.user.thredded_display_name,
               topic_title: @post.postable.title)
           ].compact.join
    end
  end
end
