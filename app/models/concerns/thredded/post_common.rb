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
    def filtered_content(view_context, users_provider: -> (names) { readers_from_user_names(names) })
      Thredded::ContentFormatter.new(view_context, users_provider: users_provider).format_content(content)
    end

    private

    def ensure_user_detail
      build_user_detail if user && !user_detail
    end
  end
end
