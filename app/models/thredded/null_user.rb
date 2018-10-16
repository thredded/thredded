# frozen_string_literal: true

module Thredded
  # A Thredded::NullUser stands in place of a real (mainapp supplied) User when:
  #
  # * user is not logged in (ie. the thredded_current_user)
  # * a user that was hard-deleted
  #   (e.g. if a post was made by a user, and then that user is destroyed, the post's user ID is nullified).
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
      nil
    end

    def name
      I18n.t('thredded.null_user_name')
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

    def thredded_display_name
      to_s
    end
  end
end
