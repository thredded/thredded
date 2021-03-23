 # frozen_string_literal: true

module Thredded
  class TopicMovie < Thredded::Topic
    belongs_to :user_detail,
               primary_key:   :user_id,
               foreign_key:   :user_id,
               inverse_of:    :topics,
               counter_cache: :movies_count,
               **(Thredded.rails_gte_51? ? { optional: true } : {})

    belongs_to :messageboard,
               touch: true,
               inverse_of: :topics,
               counter_cache: :movies_count
  end
end
