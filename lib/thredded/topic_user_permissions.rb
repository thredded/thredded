module Thredded
  class TopicUserPermissions
    attr_reader :topic, :user, :user_details, :messageboard

    def initialize(topic, user, user_details)
      @topic = topic
      @messageboard = topic.messageboard
      @user = user
      @user_details = user_details || UserDetail.new
    end

    def creatable?
      member? || messageboard_restrictions_allow?
    end

    def adminable?
      superadmin? || administrates_messageboard?
    end

    def editable?
      superadmin? || administrates_messageboard? || started_by_user?
    end

    def readable?
      MessageboardUserPermissions.new(messageboard, user).readable?
    end

    private

    def messageboard_restrictions_allow?
      user.valid? &&
        (
          messageboard.public? ||
          messageboard.restricted_to_logged_in? ||
          messageboard.posting_for_logged_in?
        )
    end

    def member?
      user.valid? && messageboard.has_member?(user)
    end

    def superadmin?
      user_details.superadmin?
    end

    def started_by_user?
      topic.user_id == user.id
    end

    def administrates_messageboard?
      user.valid? && messageboard.member_is_a?(user, 'admin')
    end
  end
end
