# frozen_string_literal: true

module Thredded
  class PrivateTopic < ActiveRecord::Base
    include Thredded::TopicCommon

    scope :for_user, ->(user) { joins(:private_users).merge(PrivateUser.where(user_id: user.id)) }

    extend FriendlyId
    friendly_id :slug_candidates,
                use:            %i[history reserved],
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(%w[new])

    belongs_to :user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_private_topics,
               optional: true
    belongs_to :user_detail,
               primary_key:   :user_id,
               foreign_key:   :user_id,
               inverse_of:    :private_topics,
               optional: true

    has_many :posts,
             class_name:  'Thredded::PrivatePost',
             foreign_key: :postable_id,
             inverse_of:  :postable,
             dependent:   :destroy
    has_one :first_post, # rubocop:disable Rails/InverseOf
            -> { order_oldest_first },
            class_name: 'Thredded::PrivatePost',
            foreign_key: :postable_id
    has_one :last_post, # rubocop:disable Rails/InverseOf
            -> { order_newest_first },
            class_name: 'Thredded::PrivatePost',
            foreign_key: :postable_id
    has_many :private_users,
             inverse_of: :private_topic,
             dependent: :delete_all
    has_many :users, through: :private_users
    has_many :user_read_states,
             class_name: 'Thredded::UserPrivateTopicReadState',
             foreign_key: :postable_id,
             inverse_of: :postable,
             dependent: :delete_all

    # Private topics with that have exactly the given participants.
    scope :has_exact_participants, ->(users) {
      private_users = Thredded::PrivateUser.arel_table
      joins(:private_users)
        .group(arel_table[:id])
        .having(
          Arel::Nodes::And.new(
            users.map do |user|
              Arel::Nodes::Count.new([private_users[:user_id].eq(user.id).or(Arel.sql('NULL'))]).eq(1)
            end
          ).and(Arel::Nodes::Count.new([private_users[:user_id].not_in(users.map(&:id)).or(Arel.sql('NULL'))]).eq(0))
        )
    }

    validates_each :users do |model, _attr, users|
      # Must include the creator + at least one other user
      model.errors.add(:user_ids, I18n.t('thredded.private_topics.errors.user_ids_length')) if users.length < 2
      unless users.include?(model.user)
        # This never happens in the UI, so we don't need to i18n the message.
        model.errors.add(:user_ids, 'must include in user_ids')
      end
    end

    before_validation :ensure_user_in_private_users

    # Finds the topic by its slug or ID, or raises Thredded::Errors::PrivateTopicNotFound.
    # @param slug_or_id [String]
    # @return [Thredded::PrivateTopic]
    # @raise [Thredded::Errors::PrivateTopicNotFound] if the topic with the given slug does not exist.
    def self.friendly_find!(slug_or_id)
      friendly.find(slug_or_id)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::PrivateTopicNotFound
    end

    def public?
      false
    end

    def should_generate_new_friendly_id?
      title_changed?
    end

    def normalize_friendly_id(input)
      Thredded.slugifier.call(input.to_s)
    end

    private

    def slug_candidates
      [
        :title,
        [:title, '-topic']
      ]
    end

    def ensure_user_in_private_users
      # TODO: investigate performance of this. Seems to take a long time and be repeatedly called in tests
      #       can we avoid callling this so often
      users << user if user.present? && !users.include?(user)
    end

    class << self
      def post_class
        Thredded::PrivatePost
      end

      # @param [Thredded.user_class] user
      # @return [Array<[PrivateTopic, PrivateUserTopicReadState]>]
      def with_read_states(user)
        if user.thredded_anonymous?
          current_scope.map do |topic|
            [topic, Thredded::NullUserTopicReadState.new(posts_count: topic.posts_count)]
          end
        else
          read_states_by_postable = read_states_by_postable_hash(user)
          current_scope.map do |topic|
            [
              topic,
              read_states_by_postable[topic] || Thredded::NullUserTopicReadState.new(posts_count: topic.posts_count)
            ]
          end
        end
      end
    end
  end
end
