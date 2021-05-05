# frozen_string_literal: true

module Thredded
  class BrowserNotifier
    def human_name
      'als Browser-Benachrichtigung'
    end

    def key
      'browser'
    end

    def new_post(post, users)
      users.map do | user |
        Thredded::Notification.new(
          user: user,
          name: "#{ post.user.thredded_display_name } kommentierte #{ post.postable.title }",
          url: "#{ Rails.configuration.frontend_url }forum/#{ post.messageboard.slug }/#{ post.postable.id }"
        ).save!
      end
    end

    def new_private_post(post, users)
      #  not implemented in frontend yet
    end

    def updated_moderation_state(moderation_state, user_detail)
      Thredded::Notification.new(
        user: user_detail.user,
        name: moderation_state == "blocked" ? "Du wurdest von einem Brickboard-Admin gesperrt!" : "Dein Account wurde soeben bestätigt!"
      ).save!
    end

    def new_relaunch_user(relaunch_user)
      # ignore
    end

    # @param badge [Thredded::Badge]
    # @param user [Thredded.user_class]
    def new_badge(badge, user)
      Thredded::Notification.new(
        user: user,
        name: "Du hast soeben das Badge \"#{ badge.title }\" erhalten!",
        url: "#{ Rails.configuration.frontend_url }profil/#{ user.id }"
      ).save!
    end
  end
end
