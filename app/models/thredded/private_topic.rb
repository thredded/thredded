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
      users.map { |user| user.to_s.capitalize }.to_sentence
    end

    def self.unread_privates?(user)
      brand_new_private_topics?(user) || latest_private_topic_unread?(user)
    end

    private

    def self.brand_new_private_topics?(user)
      user_private_topic_count(user) > 0 && latest_private_topic_read_date(user).blank?
    end

    def self.latest_private_topic_unread?(user)
      latest_private_topic_date(user) > latest_private_topic_read_date(user)
    end

    def self.latest_private_topic_date(user)
      user.thredded_private_topics.maximum('updated_at')
    end

    def self.latest_private_topic_read_date(user)
      user
      .thredded_private_topics
      .includes(:user_topic_reads)
      .where('thredded_user_topic_reads.user_id = ?', user.id)
      .references(:user_topic_reads)
      .maximum('thredded_user_topic_reads.updated_at')
    end

    def self.user_private_topic_count(user)
      user.thredded_private_topics.count
    end
  end
end
