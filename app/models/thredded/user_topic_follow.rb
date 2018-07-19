# frozen_string_literal: true

module Thredded
  class UserTopicFollow < ActiveRecord::Base
    enum reason: %i[manual posted mentioned auto]

    belongs_to :user, inverse_of: :thredded_topic_follows, class_name: Thredded.user_class_name
    belongs_to :topic, inverse_of: :user_follows

    validates :user_id, presence: true
    validates :topic_id, presence: true

    # shim to behave like postable-related (though actually only ever related to topic)
    alias_attribute :postable_id, :topic_id
    alias_attribute :postable, :topic

    # Creates a follow or finds the existing one.
    #
    # This method is safe to call concurrently from different processes. Lookup and creation happen in a transaction.
    # If an ActiveRecord::RecordNotUnique error is raised, the find is retried.
    #
    # @return [Thredded::UserTopicFollow]
    def self.create_unless_exists(user_id, topic_id, reason = :manual)
      uncached do
        transaction(requires_new: true) do
          create_with(reason: reason).find_or_create_by(user_id: user_id, topic_id: topic_id)
        end
      end
    rescue ActiveRecord::RecordNotUnique
      # The record has been created from another connection, retry to find it.
      retry
    end
  end
end
