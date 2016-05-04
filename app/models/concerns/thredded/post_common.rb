# frozen_string_literal: true
module Thredded
  module PostCommon
    extend ActiveSupport::Concern

    WHITELIST_TRANSFORMERS = HTML::Pipeline::SanitizationFilter::WHITELIST[:transformers] + [
      lambda do |env|
        node = env[:node]

        a_tags = node.css('a')
        a_tags.each do |a_tag|
          if a_tag['href'].starts_with? 'http'
            a_tag['target'] = '_blank'
            a_tag['rel'] = 'nofollow noopener'
          end
        end
      end
    ].freeze

    WHITELIST_ELEMENTS = HTML::Pipeline::SanitizationFilter::WHITELIST[:elements] + [
      'iframe',
    ].freeze

    WHITELIST = HTML::Pipeline::SanitizationFilter::WHITELIST.deep_merge(
      elements: WHITELIST_ELEMENTS,
      transformers: WHITELIST_TRANSFORMERS,
      attributes: {
        'a' => %w(href rel),
        'iframe' => %w(src width height frameborder allowfullscreen sandbox seamless)
      },
      add_attributes: {
        'iframe' => {
          'seamless' => 'seamless',
          'sandbox' => 'allow-forms allow-scripts'
        }
      }
    ).freeze

    included do
      paginates_per 50

      delegate :email, to: :user, prefix: true, allow_nil: true

      has_many :post_notifications, as: :post, dependent: :destroy

      validates :content, presence: true

      scope :order_oldest_first, -> { order(id: :asc) }
      scope :order_recent_first, -> { order(id: :desc) }

      after_commit :update_parent_last_user_and_timestamp, on: [:create, :destroy]
      after_commit :notify_at_users, on: [:create, :update]
    end

    def page(per_page: self.class.default_per_page)
      1 + postable.posts.where('id < ?', id).count / per_page
    end

    def avatar_url
      Thredded.avatar_url.call(user)
    end

    # @param view_context [Object] the context of the rendering view.
    def filtered_content(view_context)
      pipeline = HTML::Pipeline.new(content_pipeline_filters, content_pipeline_options)
      result = pipeline.call(content, view_context: view_context)
      result[:output].to_s.html_safe
    end

    protected

    # @return [Array<HTML::Pipeline::Filter]>]
    def content_pipeline_filters
      [
        HTML::Pipeline::VimeoFilter,
        HTML::Pipeline::YoutubeFilter,
        HTML::Pipeline::BbcodeFilter,
        HTML::Pipeline::MarkdownFilter,
        HTML::Pipeline::SanitizationFilter,
        HTML::Pipeline::AtMentionFilter,
        HTML::Pipeline::EmojiFilter,
        HTML::Pipeline::AutolinkFilter,
      ]
    end

    # @return [Hash] options for HTML::Pipeline.new
    def content_pipeline_options
      {
        asset_root: Rails.application.config.action_controller.asset_host || '',
        post:       self,
        whitelist:  WHITELIST,
      }
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

    def notify_at_users
      AtNotifierJob.perform_later(self.class.name, id)
    end
  end
end
