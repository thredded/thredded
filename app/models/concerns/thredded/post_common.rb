module Thredded
  module PostCommon
    extend ActiveSupport::Concern
    included do
      paginates_per 50

      belongs_to :user, class_name: Thredded.user_class
      delegate :email, to: :user, prefix: true, allow_nil: true

      has_many :post_notifications, as: :post, dependent: :destroy

      validates :content, presence: true

      after_create :update_parent_last_user_and_timestamp
      after_commit :notify_at_users, on: [:create, :update]

      extend ClassMethods
    end

    def avatar_url
      Thredded.avatar_url.call(user)
    end

    def user_anonymous?
      user.try(:thredded_anonymous?)
    end

    # @param view_context [Object] the context of the rendering view.
    def filtered_content(view_context)
      pipeline = HTML::Pipeline.new(
        [
          html_filter_for_pipeline,
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
        asset_root: Thredded.asset_root,
        post:       self,
        whitelist:  sanitize_whitelist
      }
    end

    def sanitize_whitelist
      HTML::Pipeline::SanitizationFilter::WHITELIST.deep_merge(
        attributes:   {
          'code'       => ['class'],
          'img'        => %w(src class width height),
          'blockquote' => ['class'],
        },
        transformers: [(lambda do |env|
          node      = env[:node]
          node_name = env[:node_name]

          return if env[:is_whitelisted] || !node.element?
          return if node_name != 'iframe'
          return if (node['src'] =~ %r{\A(https?:)?//(?:www\.)?youtube(?:-nocookie)?\.com/}).nil?

          Sanitize.node!(
            node,
            elements:   %w(iframe),
            attributes: {
              'iframe' => %w(allowfullscreen frameborder height src width)
            }
          )

          { node_whitelist: [node] }
        end)]
      )
    end

    def html_filter_for_pipeline
      if filter == 'bbcode'
        HTML::Pipeline::BbcodeFilter
      else
        HTML::Pipeline::MarkdownFilter
      end
    end

    def update_parent_last_user_and_timestamp
      postable.update!(last_user: user, updated_at: Time.zone.now)
    end

    def notify_at_users
      AtNotifierJob.queue.send_at_notifications(self.class.name, id)
    end

    module ClassMethods
      def filters
        %w(bbcode markdown)
      end
    end
  end
end
