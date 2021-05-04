# frozen_string_literal: true

module Thredded
  class Like < ActiveRecord::Base
    belongs_to :topic, inverse_of: :likes
    belongs_to :user, class_name: Thredded.user_class_name, inverse_of: :thredded_likes

    def self.find!(id)
      find(id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::LikeNotFound
    end
  end
end
