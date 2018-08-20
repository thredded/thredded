# frozen_string_literal: true

module Thredded
  class Category < ActiveRecord::Base
    extend FriendlyId
    belongs_to :messageboard
    has_many :topic_categories, inverse_of: :category, dependent: :delete_all
    has_many :topics, through: :topic_categories
    friendly_id :name, use: %i[history scoped], scope: :messageboard

    validates :name, presence: true
    validates :messageboard_id, presence: true

    def normalize_friendly_id(input)
      Thredded.slugifier.call(input.to_s)
    end
  end
end
