require_relative './user_permissions/read/all'
require_relative './user_permissions/write/all'
require_relative './user_permissions/message/readers_of_writeable_boards'
require_relative './user_permissions/moderate/if_moderator_column_true'
require_relative './user_permissions/admin/if_admin_column_true'

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
      end

      with_options dependent: :destroy, foreign_key: 'user_id', inverse_of: :user do |opt|
        opt.has_many :thredded_notification_preferences, class_name: 'Thredded::NotificationPreference'
        opt.has_many :thredded_private_users, class_name: 'Thredded::PrivateUser'
        opt.has_many :thredded_read_topics, class_name: 'Thredded::UserTopicRead'
        opt.has_one :thredded_user_detail, class_name: 'Thredded::UserDetail'
        opt.has_one :thredded_user_preference, class_name: 'Thredded::UserPreference'
      end

      has_many :thredded_private_topics,
               through:    :thredded_private_users,
               class_name: 'Thredded::PrivateTopic',
               source:     :private_topic
    end

    def thredded_anonymous?
      false
    end
  end
end
