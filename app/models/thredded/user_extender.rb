# frozen_string_literal: true
module Thredded
  module UserExtender
    extend ActiveSupport::Concern

    include ::Thredded::UserPermissions::Read::All
    include ::Thredded::UserPermissions::Write::All
    include ::Thredded::UserPermissions::Message::ReadersOfWriteableBoards
    include ::Thredded::UserPermissions::Moderate::IfModeratorColumnTrue
    include ::Thredded::UserPermissions::Admin::IfAdminColumnTrue

    included do
      with_options dependent: :nullify, foreign_key: 'user_id', inverse_of: :user do |opt|
        opt.has_many :thredded_posts, class_name: 'Thredded::Post'
        opt.has_many :thredded_topics, class_name: 'Thredded::Topic'
        opt.has_many :thredded_private_posts, class_name: 'Thredded::PrivatePost'
        opt.has_many :thredded_private_topics, class_name: 'Thredded::PrivateTopic'
      end

      with_options dependent: :nullify, foreign_key: 'last_user_id', inverse_of: :last_user do |opt|
        opt.has_many :thredded_last_user_topics, class_name: 'Thredded::Topic'
        opt.has_many :thredded_last_user_private_topics, class_name: 'Thredded::PrivateTopic'
      end

      with_options dependent: :destroy, foreign_key: 'user_id', inverse_of: :user do |opt|
        opt.has_many :thredded_user_messageboard_preferences, class_name: 'Thredded::UserMessageboardPreference'
        opt.has_many :thredded_private_users, class_name: 'Thredded::PrivateUser'
        opt.has_many :thredded_topic_read_states, class_name: 'Thredded::UserTopicReadState'
        opt.has_many :thredded_private_topic_read_states, class_name: 'Thredded::UserPrivateTopicReadState'
        opt.has_one :thredded_user_detail, class_name: 'Thredded::UserDetail'
        opt.has_one :thredded_user_preference, class_name: 'Thredded::UserPreference'
      end

      has_many :thredded_private_topics,
               through:    :thredded_private_users,
               class_name: 'Thredded::PrivateTopic',
               source:     :private_topic
    end

    def thredded_user_preference
      super || build_thredded_user_preference
    end

    def thredded_anonymous?
      false
    end
  end
end
