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
    validates :position, presence: true, on: :update
    before_save :ensure_position, on: :create

    def ensure_position
      recalculate_position
      self.position ||= (created_at || Time.zone.now).to_i
    end

    has_many :categories, dependent: :destroy
    has_many :user_messageboard_preferences, dependent: :destroy
    has_many :posts, dependent: :destroy
    has_many :topics, dependent: :destroy, inverse_of: :messageboard

    belongs_to :last_topic, class_name: 'Thredded::Topic'

    has_many :user_details, through: :posts
    has_many :messageboard_users,
             inverse_of:  :messageboard,
             foreign_key: :thredded_messageboard_id,
             dependent: :destroy
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

    default_scope { where(closed: false) }

    scope :top_level_messageboards, -> { where(group: nil) }
    scope :by_messageboard_group, ->(group) { where(group: group.id) }
    scope :ordered, ->() { order(position: :asc, id: :desc) }
    scope :ordered_by_group, ->() { includes(:group).order('thredded_messageboard_groups.position asc').ordered }

    def last_user
      last_topic.try(:last_user)
    end

    def slug_candidates
      [
        :name,
        [:name, '-board']
      ]
    end

    def update_last_topic!
      return if destroyed?
      self.last_topic = topics.order_recently_posted_first.moderation_state_visible_to_all.first
      recalculate_position
      save! if last_topic_id_changed? || position_changed?
    end

    def recalculate_position
      case Thredded.messageboards_order
      when :last_post_at_desc
        self.position = if last_topic
                          -last_topic.last_post_at.to_i
                        elsif created_at
                          -created_at.to_i
                        end
      when :topics_count_desc
        self.position = -topics_count
      end
    end

    def recalculate_position!
      recalculate_position
      save! if position_changed?
    end

    def self.recalculate_positions!
      return if Thredded.messageboards_order == :position
      scope = if Thredded.messageboards_order == :last_post_at_desc
                all.includes(:last_topic)
              else
                all
              end
      scope.each(&:recalculate_position!)
    end
  end
end
