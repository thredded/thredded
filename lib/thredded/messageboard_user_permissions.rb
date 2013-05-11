module Thredded
  class MessageboardUserPermissions
    attr_reader :messageboard, :user

    def initialize(messageboard, user)
      @messageboard = messageboard
      @user = user
    end

    def readable?
      (messageboard.restricted_to_private? && messageboard.has_member?(user)) ||
      (messageboard.restricted_to_logged_in? && user.valid?) ||
      messageboard.public?
    end

    def postable?
      if messageboard.posting_for_anonymous? &&
        (messageboard.restricted_to_private? || messageboard.restricted_to_logged_in?)
          false
      else
        messageboard.posting_for_anonymous? ||
          (messageboard.posting_for_logged_in? && user.try(:valid?)) ||
          (messageboard.posting_for_members? && messageboard.has_member?(user))
      end
    end
  end
end
