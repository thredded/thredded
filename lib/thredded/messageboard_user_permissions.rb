# frozen_string_literal: true
module Thredded
  class MessageboardUserPermissions
    attr_reader :messageboard, :user

    def initialize(messageboard, user)
      @messageboard = messageboard
      @user = user
    end

    def readable?
      user.thredded_can_read_messageboards.include?(messageboard)
    end

    def postable?
      user.thredded_can_write_messageboards.include?(messageboard)
    end

    def moderatable?
      user.thredded_can_moderate_messageboards.include?(messageboard)
    end
  end
end
