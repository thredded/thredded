# frozen_string_literal: true

module Thredded
  # @abstract Classes that include this module are expected to implement {#readers}.
  # @!method readers
  #     @abstract
  #     @return [ActiveRecord::Relation<Thredded.user_class>] users from that can read this post.
  module PostCommon
    extend ActiveSupport::Concern

    included do
      paginates_per Thredded.posts_per_page

      delegate :email, to: :user, prefix: true, allow_nil: true

      validates :content, presence: true

      scope :order_oldest_first, -> { order(created_at: :asc, id: :asc) }
      scope :order_newest_first, -> { order(created_at: :desc, id: :desc) }

      scope :preload_first_topic_post, -> {
        posts_table_name = quoted_table_name
        result = all
        owners_by_id = result.each_with_object({}) { |r, h| h[r.postable_id] = r.postable }
        next result if owners_by_id.empty?
        preloader = Thredded::Compat.association_preloader(
          records: owners_by_id.values, associations: [:first_post],
          scope: unscoped.where(<<~SQL.delete("\n"))
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

      before_validation :ensure_user_detail, on: :create

      after_commit :update_unread_posts_count, on: %i[create destroy]
    end

    def avatar_url
      Thredded.avatar_url.call(user)
    end

    def calculate_page(postable_posts, per_page)
      1 + postable_posts.where(postable_posts.arel_table[:created_at].lt(created_at)).count / per_page
    end

    # @param view_context [Object] the context of the rendering view.
    # @return [String] formatted and sanitized html-safe post content.
    def filtered_content(view_context, users_provider: ::Thredded::UsersProvider, **options)
      Thredded::ContentFormatter.new(
        view_context, users_provider: users_provider, users_provider_scope: readers, **options
      ).format_content(content)
    end

    def first_post_in_topic?
      postable.first_post == self
    end

    # Marks all the posts from the given one as unread for the given user
    # @param [Thredded.user_class] user
    def mark_as_unread(user)
      if previous_post.nil?
        read_state = postable.user_read_states.find_by(user_id: user.id)
        read_state&.destroy
      else
        postable.user_read_states.touch!(user.id, previous_post, overwrite_newer: true)
      end
    end

    def previous_post
      @previous_post ||= postable.posts.order_newest_first.find_by('created_at < ?', created_at)
    end

    protected

    def update_unread_posts_count
      return if destroyed_by_association
      postable.user_read_states.update_post_counts!
    end

    private

    def ensure_user_detail
      build_user_detail if user && !user_detail
    end
  end
end
