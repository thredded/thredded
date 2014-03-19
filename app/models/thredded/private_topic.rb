module Thredded
  class PrivateTopic < Thredded::Topic
    has_many :private_users
    has_many :users, through: :private_users

    def self.including_roles_for(user)
      joins(messageboard: :roles)
        .where(thredded_roles: {user_id: user.id})
    end

    def self.for_user(user)
      joins(:private_users)
        .where(thredded_private_users: {user_id: user.id})
    end

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
      users.map{ |user| user.to_s.capitalize }.to_sentence
    end

    def self.unread_privates?(user)
      max_private_topic_read =
        user
        .thredded_private_topics
        .includes(:user_topic_reads)
        .where('thredded_user_topic_reads.user_id = ?', user.id)
        .references(:user_topic_reads)
        .maximum('thredded_user_topic_reads.updated_at')
      return true if max_private_topic_read.blank?

      max_private_topic_date = user.thredded_private_topics.maximum('updated_at')
      max_private_topic_date > max_private_topic_read
    end
  end
end
