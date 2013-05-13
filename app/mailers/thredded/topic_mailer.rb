class TopicMailer < ActionMailer::Base
  def message_notification(topic_id, emails)
    @topic = Topic.find(topic_id)
    headers['X-SMTPAPI'] = %Q{{"category": ["thredded_#{@topic.messageboard.name}","at_notification"]}}
    site = @topic.messageboard.site
    reply_to = "#{@topic.hash_id}@#{site.incoming_email_host}"
    no_reply = site.email_from
    subject = "#{site.email_subject_prefix} #{@topic.title}"

    mail from: no_reply, to: no_reply, bcc: emails,
      reply_to: reply_to, subject: subject
  end
end
