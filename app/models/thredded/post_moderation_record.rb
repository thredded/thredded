# frozen_string_literal: true

module Thredded
  class PostModerationRecord < ActiveRecord::Base
    include Thredded::ModerationState
    enum previous_moderation_state: moderation_states, _prefix: :previous
    validates :previous_moderation_state, presence: true

    scope :order_newest_first, -> { order(created_at: :desc, id: :desc) }

    belongs_to :messageboard, inverse_of: :post_moderation_records

    belongs_to :post,
               inverse_of: :moderation_records,
               optional: true
    belongs_to :post_user,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_post_moderation_records,
               optional: true
    belongs_to :moderator,
               class_name: Thredded.user_class_name,
               inverse_of: :thredded_post_moderation_records,
               optional: true

    validates_each :moderation_state do |record, attr, value|
      record.errors.add attr, "Post moderation_state is already #{value}" if record.previous_moderation_state == value
    end

    scope :preload_first_topic_post, -> {
      posts_table_name = Thredded::Post.quoted_table_name
      result = all
      owners_by_id = result.each_with_object({}) do |r, h|
        h[r.post.postable_id] = r.post.postable if r.post
      end
      next result if owners_by_id.empty?
      preloader = ActiveRecord::Associations::Preloader.new.preload(
        owners_by_id.values, :first_post,
        Thredded::Post.unscoped.where(<<~SQL.delete("\n"))
          #{posts_table_name}.created_at = (
          SELECT MAX(p2.created_at) from #{posts_table_name} p2 WHERE p2.postable_id = #{posts_table_name}.postable_id)
      SQL
      )
      preloader[0].preloaded_records.each do |post|
        topic = owners_by_id.delete(post.postable_id)
        next unless topic
        topic.association(:first_post).target = post
      end
      result
    }

    paginates_per Thredded.posts_per_page

    # @return [ActiveRecord::Relation<Thredded.user_class>] users that can read the moderated post.
    def post_readers
      Thredded.user_class.thredded_messageboards_readers([messageboard])
    end

    # @param [Thredded.user_class] moderator
    # @param [Thredded::Post] post
    # @param [Symbol, String] previous_moderation_state
    # @param [Symbol, String] moderation_state
    # @return [Thredded::PostModerationRecord] the newly created persisted record
    def self.record!(moderator:, post:, previous_moderation_state:, moderation_state:)
      create!(
        previous_moderation_state: previous_moderation_state,
        moderation_state:          moderation_state,
        moderator:                 moderator,
        post:                      post,
        post_content:              post.content,
        post_user:                 post.user,
        post_user_name:            post.user.try(:thredded_display_name),
        messageboard_id:           post.messageboard_id,
      )
    end
  end
end
