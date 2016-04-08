require 'thredded/topics_search'

module Thredded
  class Topic < ActiveRecord::Base
    include TopicCommon

    scope :for_messageboard, -> messageboard { where(messageboard_id: messageboard.id) }

    scope :order_sticky_first, -> { order(sticky: :desc) }

    extend FriendlyId
    friendly_id :slug_candidates,
                use:            [:history, :reserved, :scoped],
                scope:          :messageboard,
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(%w(topics))

    belongs_to :messageboard,
               counter_cache: true,
               touch: true,
               inverse_of: :topics
    validates_presence_of :messageboard_id

    belongs_to :user_detail,
               primary_key:   :user_id,
               foreign_key:   :user_id,
               inverse_of:    :topics,
               counter_cache: :topics_count

    has_many :posts,
             class_name:  'Thredded::Post',
             foreign_key: :postable_id,
             inverse_of:  :postable,
             dependent:   :destroy
    has_many :topic_categories, dependent: :destroy
    has_many :categories, through: :topic_categories
    has_many :user_topic_reads, dependent: :destroy

    def self.stuck
      where(sticky: true)
    end

    def self.unstuck
      where(sticky: false)
    end

    # @return [ActiveRecord::Relation<Topic>]
    def self.search(query)
      ::Thredded::TopicsSearch.new(query, self).search
    end

    def self.find_by_slug_with_user_topic_reads!(slug)
      includes(:user_topic_reads).friendly.find(slug)
    rescue ActiveRecord::RecordNotFound
      raise Thredded::Errors::TopicNotFound
    end

    def decorate
      TopicDecorator.new(self)
    end

    def public?
      true
    end

    # rubocop:disable all
    def self.inherited(child)
      child.instance_eval do
        def model_name
          Topic.model_name
        end
      end

      super
    end
    # rubocop:enable all

    def self.select_options
      subclasses.map(&:to_s).sort
    end

    def self.recent
      limit(10)
    end

    def updating?
      id.present?
    end

    def categories_to_sentence
      categories.map(&:name).to_sentence if categories.any?
    end

    def users_to_sentence
      []
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
