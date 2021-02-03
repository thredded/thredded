# frozen_string_literal: true

module Thredded
  class Category < ActiveRecord::Base
    #extend FriendlyId
    has_many :topic_categories, inverse_of: :category, dependent: :delete_all
    has_many :topics, -> { order('created_at DESC') }, through: :topic_categories

    validates :name, presence: true, uniqueness: true

    has_one_attached :category_icon

    #validates :category_icon, file_size: { less_than_or_equal_to: 500.kilobytes },
    #         file_content_type: { allow: %w[image/jpeg image/jpg] }

  end
end
