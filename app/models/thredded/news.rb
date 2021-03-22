# frozen_string_literal: true

module Thredded
  class News < ActiveRecord::Base

    validates :title, presence: true
    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_news,
               **(Thredded.rails_gte_51? ? { optional: true } : {})

    has_one_attached :news_banner

    validates :news_banner, file_size: { less_than_or_equal_to: 500.kilobytes },
                              file_content_type: { allow: %w[image/jpeg image/jpg] }

    def self.find!(slug_or_id)
      find(slug_or_id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::CategoryNotFound
    end
  end
end
