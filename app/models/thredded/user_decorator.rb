require 'active_support/concern'

module Thredded
  module UserDecorator
    extend ActiveSupport::Concern

    included do
      has_many :thredded_topics, class_name: 'Thredded::Topic', foreign_key: 'user_id'
      has_many :thredded_posts, class_name: 'Thredded::Post', foreign_key: 'user_id'
      has_many :thredded_roles, class_name: 'Thredded::Role', foreign_key: 'user_id'
      has_many :thredded_preferences, class_name: 'Thredded::Preference', foreign_key: 'user_id'
      has_many :thredded_private_users, class_name: 'Thredded::PrivateUser', foreign_key: 'user_id'
      has_many :thredded_private_topics, through: :thredded_private_users, class_name: 'Thredded::PrivateTopic', source: :private_topic
      has_one :thredded_user_detail, class_name: 'Thredded::UserDetail', foreign_key: 'user_id'
    end
  end
end
