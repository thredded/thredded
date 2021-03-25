# frozen_string_literal: true

module Thredded
  class PrivateTopicMailer < Thredded::BaseMailer
    def message_notification(post_id, emails)
      @post = find_record Thredded::PrivatePost, post_id
      email_details = Thredded::TopicEmailView.new(@post.postable)
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('private_topic_mailer')
      attachments.inline["bb_logo.jpg"] = File.read("#{Rails.root}/app/assets/images/email/bb_logo.jpg")


      mail from: email_details.no_reply,
           to: email_details.no_reply,
           bcc: emails,
           subject: [
             Thredded.email_outgoing_prefix,
             t('thredded.emails.message_notification.subject',
               user: @post.user.thredded_display_name,
               topic_title: @post.postable.title)
           ].compact.join
    end
  end
end
