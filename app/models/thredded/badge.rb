# frozen_string_literal: true

module Thredded
  class Badge < ActiveRecord::Base
    scope :visible, -> { where(secret: false) }

    has_many :user_badges, inverse_of: :badge, dependent: :delete_all
    has_many :users, -> { order('created_at DESC') }, through: :user_badges

    validates :title, presence: true, uniqueness: true
    validates :description, presence: true

    has_one_attached :badge_icon

    validates :badge_icon, file_size: { less_than_or_equal_to: 500.kilobytes },
              file_content_type: { allow: %w[image/jpeg image/jpg] }

    def self.find!(id)
      find(id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::BadgeNotFound
    end
  end
end