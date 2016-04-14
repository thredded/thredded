# frozen_string_literal: true
module Thredded
  class UserTopicRead < ActiveRecord::Base
    belongs_to :topic
    belongs_to :user, class_name: Thredded.user_class, inverse_of: :thredded_read_topics
    belongs_to :farthest_post,
      class_name: 'Thredded::Post', foreign_key: 'post_id'
    validates :user_id, uniqueness: { scope: :topic }
    belongs_to :post
  end
end
