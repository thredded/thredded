# frozen_string_literal: true

module Thredded
  module BadgeAssignment
    extend ActiveSupport::Concern
    USER_DETAIL_BADGES_PATH = Rails.root.join('config/badges/user_stats.yaml')

    included do
      after_commit :check_for_badges, on: :create
    end

    protected

    def check_for_badges
      user = self.user
      get_badge_from_messageboard(user)
      get_badge_from_topic(user)
      get_badges_for_user_details(user)
    end

    private

    # @param user [Thredded.user_class]
    def get_badge_from_messageboard user
      user.thredded_badges |= [self.messageboard.badge] if self.messageboard.badge
    end

    # @param user [Thredded.user_class]
    def get_badge_from_topic user
      user.thredded_badges |= [self.postable.badge] if self.postable.badge
    end

    # @param user [Thredded.user_class]
    def get_badges_for_user_details user
      if File.exist?(USER_DETAIL_BADGES_PATH)
        config = YAML.load(File.read(USER_DETAIL_BADGES_PATH), symbolize_names: true).values
        user_detail = user.thredded_user_detail
        badges = []

        config.each do |entry|
          begin
            badge = Thredded::Badge.find!(entry[:badge_id])
          rescue Thredded::Errors::BadgeNotFound
            break
          end
          if entry[:posts_count] && user_detail.posts_count >= entry[:posts_count]
            badges.push(badge)
          end
          if entry[:movies_count] && user_detail.movies_count >= entry[:movies_count]
            badges.push(badge)
          end
        end

        user.thredded_badges |=  badges
      end
    end
  end
end
