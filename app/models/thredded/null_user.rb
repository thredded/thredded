module Thredded
  class NullUser
    def admins?(messageboard)
      false
    end

    def thredded_private_topics
      false
    end

    def can_read_messageboard?(messageboard)
      messageboard.public?
    end

    def id
      0
    end

    def member_of?(messageboard)
      false
    end

    def name
      'Anonymous User'
    end

    def valid?
      false
    end
  end
end
