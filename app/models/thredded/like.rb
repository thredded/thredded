# frozen_string_literal: true

module Thredded
  class Like < ActiveRecord::Base
    validates_uniqueness_of :topic_id, :scope => :user_id
    belongs_to :topic, inverse_of: :likes, counter_cache: :likes_count
    belongs_to :user, class_name: Thredded.user_class_name, inverse_of: :thredded_likes

    def self.find!(user_id, topic_id)
      like = Like.where(user_id: user_id, topic_id: topic_id)
      if !like.empty?
        find(like.first.id)
      else
        raise Thredded::Errors::LikeNotFound
      end
    end
  end
end
