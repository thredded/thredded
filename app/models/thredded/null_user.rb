module Thredded
  class NullUser
    def admins?(_)
      false
    end

    def thredded_private_topics
      Thredded::PrivateTopic.none
    end

    def can_read_messageboard?(messageboard)
      messageboard.public?
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

    def anonymous?
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
