# frozen_string_literal: true
module Thredded
  class MessageboardPolicy
    # @param user [Thredded.user_class]
    # @param messageboard [Thredded::Messageboard]
    def initialize(user, messageboard)
      @user = user
      @messageboard = messageboard
    end

    def create?
      @user.thredded_admin?
    end

    def read?
      @user.thredded_admin? || @user.thredded_can_read_messageboards.include?(@messageboard)
    end

    def post?
      @user.thredded_admin? || @user.thredded_can_write_messageboards.include?(@messageboard)
    end

    def moderate?
      @user.thredded_admin? || @user.thredded_can_moderate_messageboards.include?(@messageboard)
    end
  end
end
