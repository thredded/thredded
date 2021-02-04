# frozen_string_literal: true

module Thredded
  class TopicDefault < Thredded::Topic
    belongs_to :user_detail,
               primary_key:   :user_id,
               foreign_key:   :user_id,
               inverse_of:    :topics,
               **(Thredded.rails_gte_51? ? { optional: true } : {})
  end
end
