require 'active_support/concern'

module Thredded
  module UserExtender
    extend ActiveSupport::Concern

    included do
      has_many :thredded_messageboard_preferences, class_name: 'Thredded::MessageboardPreference', foreign_key: 'user_id'
      has_many :thredded_posts, class_name: 'Thredded::Post', foreign_key: 'user_id'
      has_many :thredded_private_topics, through: :thredded_private_users, class_name: 'Thredded::PrivateTopic', source: :private_topic
      has_many :thredded_private_users, class_name: 'Thredded::PrivateUser', foreign_key: 'user_id'
      has_many :thredded_roles, class_name: 'Thredded::Role', foreign_key: 'user_id'
      has_many :thredded_topics, class_name: 'Thredded::Topic', foreign_key: 'user_id'
      has_many :thredded_read_topics, class_name: 'Thredded::UserTopicRead', foreign_key: 'user_id'
      has_many :thredded_messageboards, through: :thredded_roles, class_name: 'Thredded::Messageboard', source: :messageboard

      has_one :thredded_user_detail, class_name: 'Thredded::UserDetail', foreign_key: 'user_id'
      has_one :thredded_user_preference, class_name: 'Thredded::UserPreference', foreign_key: 'user_id'
    end
  end
end
