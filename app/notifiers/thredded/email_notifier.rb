# frozen_string_literal: true

module Thredded
  class EmailNotifier
    def initialize
      fail 'Please set Thredded.email_from in config/initializers/thredded.rb' if Thredded.email_from.blank?
    end

    def human_name
      I18n.t('thredded.email_notifier.by_email')
    end

    def key
      'email'
    end

    def new_post(post, users)
      Thredded::PostMailer.post_notification(post.id, users.map(&:email)).deliver_now
    end

    def new_private_post(post, users)
      Thredded::PrivateTopicMailer.message_notification(post.id, users.map(&:email)).deliver_now
    end

    def updated_moderation_state(moderation_state, user_detail)
      Thredded::ModerationStateMailer.moderation_state_notification(moderation_state, user_detail.id, user_detail.user.email).deliver_now
    end

    def new_relaunch_user(relaunch_user)
      Thredded::RelaunchUserMailer.new_relaunch_user(relaunch_user.id, relaunch_user.email, relaunch_user.username, relaunch_user.user_hash).deliver_now
    end

    # @param badge [Thredded::Badge]
    # @param user [Thredded.user_class]
    def new_badge(badge, user)
      # ignore, use browser_notifier because a user is normally active when obtaining a badge
    end
  end
end
