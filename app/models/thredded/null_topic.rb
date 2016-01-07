module Thredded
  class NullTopic
    def updated_at
      nil
    end

    def user
      Thredded::NullUser.new
    end

    def last_user
      Thredded::NullUser.new
    end
  end
end
