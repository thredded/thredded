# frozen_string_literal: true

module Thredded
  module BadgeAssignment
    extend ActiveSupport::Concern

    included do
      after_commit :check_for_badges, on: :create
    end

    protected

    def check_for_badges
      user = self.user
      get_badge_from_messageboard(user)
      get_badge_from_topic(user)
    end

    private

    def get_badge_from_messageboard user
      user.thredded_badges |= [self.messageboard.badge] if self.messageboard.badge
    end

    def get_badge_from_topic user
      user.thredded_badges |= [self.postable.badge] if self.postable.badge
    end
  end
end
