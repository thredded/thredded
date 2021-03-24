# frozen_string_literal: true

module Thredded
  class NotifyModeratedUser
    def initialize(moderation_state, user_detail)
      @user_detail = user_detail
      @moderation_state = moderation_state
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifier.updated_moderation_state(@moderation_state, @user_detail)
      end
    end
  end
end
