# frozen_string_literal: true
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
