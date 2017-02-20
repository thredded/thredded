# frozen_string_literal: true
module Thredded
  # @abstract Classes that include this module are expected to implement {#readers}.
  # @!method readers
  #     @abstract
  #     @return [ActiveRecord::Relation<Thredded.user_class>] users from that can read this post.
  module PostCommon
    extend ActiveSupport::Concern

    included do
      paginates_per 50

      delegate :email, to: :user, prefix: true, allow_nil: true

      has_many :post_notifications, as: :post, dependent: :destroy

      validates :content, presence: true

      scope :order_oldest_first, -> { order(created_at: :asc, id: :asc) }
      scope :order_newest_first, -> { order(created_at: :desc, id: :desc) }

      before_validation :ensure_user_detail, on: :create
    end

    def avatar_url
      Thredded.avatar_url.call(user)
    end

    def calculate_page(postable_posts, per_page)
      1 + postable_posts.where(postable_posts.arel_table[:created_at].lt(created_at)).count / per_page
    end

    # @param view_context [Object] the context of the rendering view.
    # @return [String] formatted and sanitized html-safe post content.
    def filtered_content(view_context, users_provider: ->(names) { readers_from_user_names(names) })
      Thredded::ContentFormatter.new(view_context, users_provider: users_provider).format_content(content)
    end

    def first_post_in_topic?
      postable.first_post == self
    end

    # @return [ActiveRecord::Relation<Thredded.user_class>] users from the list of user names that can read this post.
    # @api private
    def readers_from_user_names(user_names)
      DbTextSearch::CaseInsensitive
        .new(readers, Thredded.user_name_column)
        .in(user_names)
    end

    def mark_as_unread(user)
      if previous_post.nil?
        read_state = postable.user_read_states.find_by(user_id: user.id)
        read_state.destroy if read_state
      else
        read_state = postable.user_read_states.create_with(read_at: previous_post.created_at).find_or_create_by(user_id: user.id)
        read_state.update_columns(read_at: previous_post.created_at)
      end
    end

    def previous_post
      @previous_post ||= postable.posts.order_newest_first.find_by('created_at < ?', created_at)
    end

    private

    def ensure_user_detail
      build_user_detail if user && !user_detail
    end
  end
end
