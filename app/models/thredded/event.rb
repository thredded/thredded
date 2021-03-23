# frozen_string_literal: true

module Thredded
  class Event < ActiveRecord::Base

    validates :title, presence: true
    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_news,
               **(Thredded.rails_gte_51? ? { optional: true } : {})

    scope :order_by_event_date, -> { order(event_date: :desc) }
    paginates_per 10

    def self.find!(slug_or_id)
      find(slug_or_id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::EventNotFound
    end
  end
end
