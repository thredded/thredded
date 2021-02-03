# frozen_string_literal: true

module Thredded
  class NotifyModeratedUser
    def initialize(user_detail)
      @user_detail = user_detail
    end

    def run
      Thredded.notifiers.each do |notifier|
        notifier.updated_moderation_state(@user_detail)
      end
    end
  end
end
