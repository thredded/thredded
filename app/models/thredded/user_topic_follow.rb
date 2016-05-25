# frozen_string_literal: true
module Thredded
  class UserTopicFollow < ActiveRecord::Base
    REASON_MANUAL = 'manual'
    REASON_POSTED = 'posted'

    belongs_to :user, inverse_of: :thredded_topic_follows
    belongs_to :topic, inverse_of: :user_follows

    validates :user_id, presence: true
    validates :topic_id, presence: true
  end
end
