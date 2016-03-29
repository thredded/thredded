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
      has_many :thredded_notification_preferences, class_name: 'Thredded::NotificationPreference', foreign_key: 'user_id'
      has_many :thredded_posts, class_name: 'Thredded::Post', foreign_key: 'user_id'
      has_many :thredded_private_topics, through: :thredded_private_users, class_name: 'Thredded::PrivateTopic', source: :private_topic
      has_many :thredded_private_users, class_name: 'Thredded::PrivateUser', foreign_key: 'user_id'
      has_many :thredded_topics, class_name: 'Thredded::Topic', foreign_key: 'user_id'
      has_many :thredded_read_topics, class_name: 'Thredded::UserTopicRead', foreign_key: 'user_id'

      has_one :thredded_user_detail, class_name: 'Thredded::UserDetail', foreign_key: 'user_id'
      has_one :thredded_user_preference, class_name: 'Thredded::UserPreference', foreign_key: 'user_id'
    end

    def thredded_anonymous?
      false
    end
  end
end
