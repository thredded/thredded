module Thredded
  class PrivateTopic < ActiveRecord::Base
    include TopicCommon

    scope :for_user, -> (user) { joins(:private_users).merge(PrivateUser.where(user_id: user.id)) }

    extend FriendlyId
    friendly_id :slug_candidates,
                use:            [:history, :reserved],
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(%w(new))

    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_private_topics

    has_many :posts,
             class_name:  'Thredded::PrivatePost',
             foreign_key: :postable_id,
             inverse_of:  :postable,
             dependent:   :destroy
    has_one :first_post, -> { order_oldest_first },
            class_name:  'Thredded::PrivatePost',
            foreign_key: :postable_id
    has_many :private_users, inverse_of: :private_topic
    has_many :users, through: :private_users

    validates_each :users do |model, _attr, users|
      # Must include the creator + at least one other user
      if users.length < 2
        model.errors.add(:user_ids, I18n.t('thredded.private_topics.errors.user_ids_length'))
      end
      unless users.include?(model.user)
        # This never happens in the UI, so we don't need to i18n the message.
        model.errors.add(:user_ids, 'must include in user_ids')
      end
    end

    before_validation :ensure_user_in_private_users

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

    def public?
      false
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

    def ensure_user_in_private_users
      users << user if user.present? && !users.include?(user)
    end
  end
end
