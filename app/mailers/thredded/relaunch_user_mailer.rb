# frozen_string_literal: true

module Thredded
  class RelaunchUserMailer < Thredded::BaseMailer
    def new_relaunch_user(email, username)
      @email = email
      @username = username
      attachments.inline["bb_logo.jpg"] = File.read("#{Rails.root}/app/assets/images/email/bb_logo.jpg")
      email_details = Thredded::DefaultEmailView.new
      headers['X-SMTPAPI'] = email_details.smtp_api_tag('moderation_state_mailer')

      mail(from: email_details.no_reply,
           to: email,
           subject: [
             Thredded.email_outgoing_prefix,
             'Willkommen!'
           ].compact.join) do |format|
        format.html {render(layout: false)}
      end
    end
  end
end
