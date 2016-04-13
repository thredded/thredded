module Thredded
  module PostCommon
    extend ActiveSupport::Concern

    included do
      paginates_per 50

      delegate :email, to: :user, prefix: true, allow_nil: true

      has_many :post_notifications, as: :post, dependent: :destroy

      validates :content, presence: true

      scope :order_oldest_first, -> { order(id: :asc) }

      after_create :update_parent_last_user_and_timestamp
      after_commit :notify_at_users, on: [:create, :update]
    end

    def page(per_page: self.class.default_per_page)
      1 + postable.posts.where('id < ?', id).count / per_page
    end

    def avatar_url
      Thredded.avatar_url.call(user)
    end

    def user_anonymous?
      !user || user.thredded_anonymous?
    end

    # @param view_context [Object] the context of the rendering view.
    def filtered_content(view_context)
      pipeline = HTML::Pipeline.new(
        [
          HTML::Pipeline::VimeoFilter,
          HTML::Pipeline::YoutubeFilter,
          HTML::Pipeline::BbcodeFilter,
          HTML::Pipeline::MarkdownFilter,
          HTML::Pipeline::SanitizationFilter,
          HTML::Pipeline::AtMentionFilter,
          HTML::Pipeline::EmojiFilter,
          HTML::Pipeline::AutolinkFilter,
        ], context_options)

      result = pipeline.call(content, view_context: view_context)
      result[:output].to_s.html_safe
    end

    private

    def context_options
      {
        asset_root: Rails.application.config.action_controller.asset_host || '',
        post:       self,
        whitelist:  sanitize_whitelist
      }
    end

    def sanitize_whitelist
      HTML::Pipeline::SanitizationFilter::WHITELIST[:elements] += %w(
        fieldset
        legend
        blockquote
      )
      HTML::Pipeline::SanitizationFilter::WHITELIST
    end

    def update_parent_last_user_and_timestamp
      return unless postable && user

      postable.update!(last_user: user, updated_at: Time.current)
    end

    def notify_at_users
      AtNotifierJob.perform_later(self.class.name, id)
    end
  end
end
