# frozen_string_literal: true

module Thredded
  class ModerationStateMailer < Thredded::BaseMailer
    def moderation_state_notification(moderation_state, user_detail_id, email)
      @user_detail = find_record Thredded::UserDetail, user_detail_id
      @name = @user_detail.user.send(Thredded.user_name_column)
      @moderation_state = moderation_state
      email_details = Thredded::ModerationStateEmailView.new(@user_detail)
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('moderation_state_mailer')

      mail from: email_details.no_reply,
           to: email,
           subject: [
             Thredded.email_outgoing_prefix,
             'Willkommen!'
           ].compact.join
    end
  end
end
