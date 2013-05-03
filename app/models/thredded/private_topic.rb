module Thredded
  class PrivateTopic < Thredded::Topic
    has_many :private_users
    has_many :users, through: :private_users
    attr_accessible :user_id

    def add_user(user)
      if String == user.class
        user = User.find_by_name(user)
      end

      users << user
    end

    def public?
      false
    end

    def private?
      true
    end

    def user_id=(ids)
      if ids.size > 0
        self.users = User.where(id: ids.uniq)
      end
    end

    def users_to_sentence
      users.map{ |user| user.name.capitalize }.to_sentence
    end
  end
end
