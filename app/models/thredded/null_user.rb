require_relative './user_permissions/read/all'
require_relative './user_permissions/write/none'
require_relative './user_permissions/message/readers_of_writeable_boards'
require_relative './user_permissions/moderate/none'
require_relative './user_permissions/admin/none'

module Thredded
  class NullUser
    include ::Thredded::UserPermissions::Read::All
    include ::Thredded::UserPermissions::Write::None
    include ::Thredded::UserPermissions::Message::ReadersOfWriteableBoards
    include ::Thredded::UserPermissions::Moderate::None
    include ::Thredded::UserPermissions::Admin::None

    def thredded_private_topics
      Thredded::PrivateTopic.none
    end

    def id
      0
    end

    def member_of?(_)
      false
    end

    def name
      'Anonymous User'
    end

    def to_s
      name
    end

    def valid?
      false
    end

    def thredded_anonymous?
      true
    end

    def thredded_user_detail
      Thredded::UserDetail.new
    end

    def thredded_user_preference
      Thredded::UserPreference.new
    end
  end
end
