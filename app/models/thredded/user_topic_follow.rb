# frozen_string_literal: true
module Thredded
  class UserTopicFollow < ActiveRecord::Base
    REASON_MANUAL = 'manual'
    REASON_POSTED = 'posted'
    REASON_MENTIONED = 'mentioned'
    enum reason: [:manual, :posted, :mentioned]

    belongs_to :user, inverse_of: :thredded_topic_follows
    belongs_to :topic, inverse_of: :user_follows

    validates :user_id, presence: true
    validates :topic_id, presence: true

    # shim to behave like postable-related (though actually only ever related to topic)
    alias_attribute :postable_id, :topic_id
    alias_attribute :postable, :topic

    def self.create_unique(user_id, topic_id, reason = REASON_MANUAL)
      create_with(reason: reason).find_or_create_by(user_id: user_id, topic_id: topic_id)
    end
  end
end
