# frozen_string_literal: true
module Thredded
  class Messageboard < ActiveRecord::Base
    extend FriendlyId
    friendly_id :slug_candidates,
                use:            [:slugged, :reserved],
                # Avoid route conflicts
                reserved_words: ::Thredded::FriendlyIdReservedWordsAndPagination.new(
                  %w(
                    admin
                    autocomplete-users
                    messageboards
                    posts
                    preferences
                    private-posts
                    private-topics
                    theme-preview
                  )
                )

    validates :name, uniqueness: true, length: { maximum: 60 }, presence: true
    validates :topics_count, numericality: true

    has_many :categories, dependent: :destroy
    has_many :user_messageboard_preferences, dependent: :destroy
    has_many :posts, dependent: :destroy
    has_many :topics, dependent: :destroy, inverse_of: :messageboard

    # TODO: change this to a belongs_to association to be able to preload efficiently
    has_one :latest_topic, -> { order_recently_updated_first },
            class_name: 'Thredded::Topic'

    has_many :user_details, through: :posts
    has_many :messageboard_users,
             inverse_of:  :messageboard,
             foreign_key: :thredded_messageboard_id
    has_many :recently_active_user_details,
             -> { merge(Thredded::MessageboardUser.recently_active) },
             class_name: 'Thredded::UserDetail',
             through:    :messageboard_users,
             source:     :user_detail
    has_many :recently_active_users,
             class_name: Thredded.user_class,
             through:    :recently_active_user_details,
             source:     :user

    belongs_to :group,
               inverse_of: :messageboards,
               foreign_key: :messageboard_group_id,
               class_name: 'Thredded::MessageboardGroup'

    has_many :post_moderation_records, inverse_of: :messageboard, dependent: :delete_all

    default_scope { where(closed: false).order(topics_count: :desc) }

    scope :top_level_messageboards, -> { where(group: nil) }
    scope :by_messageboard_group, ->(group) { where(group: group.id) }

    def latest_user
      latest_topic.last_user
    end

    def slug_candidates
      [
        :name,
        [:name, '-board']
      ]
    end
  end
end
