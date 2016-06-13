# frozen_string_literal: true
require_dependency 'thredded/content_formatter'
module Thredded
  module PostCommon
    extend ActiveSupport::Concern

    included do
      paginates_per 50

      delegate :email, to: :user, prefix: true, allow_nil: true

      has_many :post_notifications, as: :post, dependent: :destroy

      validates :content, presence: true

      scope :order_oldest_first, -> { order(id: :asc) }
      scope :order_newest_first, -> { order(id: :desc) }

      after_commit :update_parent_last_user_and_timestamp, on: [:create, :destroy]
    end

    def avatar_url
      Thredded.avatar_url.call(user)
    end

    # @param view_context [Object] the context of the rendering view.
    # @return [String] formatted and sanitized html-safe post content.
    def filtered_content(view_context, users_provider: -> (names) { readers_from_user_names(names) })
      Thredded::ContentFormatter.new(view_context, users_provider: users_provider).format_content(content)
    end

    private

    def update_parent_last_user_and_timestamp
      return if postable.destroyed?
      last_post = if destroyed?
                    postable.posts.order_oldest_first.select(:user_id, :created_at).last
                  else
                    self
                  end
      postable.update!(last_user_id: last_post.user_id, updated_at: last_post.created_at)
    end
  end
end
