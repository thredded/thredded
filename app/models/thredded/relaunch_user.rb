# frozen_string_literal: true

module Thredded
  class RelaunchUser < ActiveRecord::Base

    validates :email, presence: true, uniqueness: true
    validates :username, presence: true, uniqueness: true

    scope :order_by_created_date, -> { order(created_at: :desc) }
    paginates_per 10

    def self.find!(slug_or_id)
      find(slug_or_id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::RelaunchUserNotFound
    end
  end
end
