# frozen_string_literal: true
module Thredded
  class EmailNotifier
    def human_name
      I18n.t('thredded.email_notifier.by_email')
    end

    def key
      'email'
    end

    def new_post(post, users)
      PostMailer.post_notification(post.id, users.map(&:email)).deliver_now
    end

    def new_private_post(post, users)
      PrivateTopicMailer.message_notification(post.postable.id, post.id, users.map(&:email)).deliver_now
    end
  end
end
