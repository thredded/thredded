module Thredded
  class NullTopic
    def updated_at
      Time.now
    end

    def user
      'Anonymous User'
    end

    def last_user
      'Anonymous User'
    end
  end
end

