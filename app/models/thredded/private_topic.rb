module Thredded
  class PrivateTopic < ActiveRecord::Base
    include TopicCommon
    extend FriendlyId
    friendly_id :slug_candidates,
                use:            [:history, :reserved],
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(%w(new))

    has_many :posts,
             class_name:  'Thredded::PrivatePost',
             foreign_key: :postable_id,
             inverse_of:  :postable,
             dependent:   :destroy
    has_many :private_users
    has_many :users, through: :private_users

    def self.find_by_slug(slug)
      friendly.find(slug)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::PrivateTopicNotFound
    end

    def decorate
      TopicDecorator.new(self)
    end

    def user_topic_reads
      []
    end

    def categories
      []
    end

    def self.for_user(user)
      joins(:private_users)
        .where(thredded_private_users: { user_id: user.id })
    end

    def add_user(user)
      if String == user.class
        user = Thredded.user_class.find_by_name(user)
      end

      users << user
    end

    def public?
      false
    end

    def user_id=(ids)
      return unless ids.size > 0

      self.users = Thredded.user_class.where(id: ids.uniq)
    end

    def users_to_sentence
      users.map { |user| user.to_s.capitalize }.to_sentence
    end

    def should_generate_new_friendly_id?
      title_changed?
    end

    private

    def slug_candidates
      [
        :title,
        [:title, '-topic']
      ]
    end
  end
end
