# frozen_string_literal: true

module Thredded
  module ApplicationHelper
    include ::Thredded::UrlsHelper
    include ::Thredded::NavHelper
    include ::Thredded::RenderHelper

    # @return [AllViewHooks] View hooks configuration.
    def view_hooks
      @view_hooks ||= Thredded.view_hooks
    end

    def thredded_container_data
      {
        'thredded-locale' => I18n.locale,
        'thredded-page-id' => content_for(:thredded_page_id),
        'thredded-root-url' => thredded.root_path
      }
    end

    def thredded_container_classes
      [
        'thredded--main-container',
        content_for(:thredded_page_id),
        "thredded--global-nav-icons-#{global_nav_icons_count}",
        ('thredded--is-moderator' if thredded_moderator?),
        ('thredded--private-messaging-enabled' if Thredded.private_messaging_enabled),
      ].compact
    end

    def global_nav_icons_count
      result = 1 # Notification Settings
      result += 1 if Thredded.private_messaging_enabled
      result += 1 if thredded_moderator?
      result
    end

    # Render the page container with the supplied block as content.
    def thredded_page(&block)
      # enable the host app to easily check whether a thredded view is being rendered:
      content_for :thredded, true
      content_for :thredded_page_content, &block
      render partial: 'thredded/shared/page'
    end

    # @param user [Thredded.user_class, Thredded::NullUser]
    # @return [String] html_safe link to the user
    def user_link(user)
      render partial: 'thredded/users/link', locals: { user: user }
    end

    # @param user [Thredded.user_class]
    # @return [String] wrapped @mention string
    def user_mention(user)
      username = user.send(Thredded.user_name_column)
      if username.include?(' ')
        %(@"#{username}")
      else
        "@#{username}"
      end
    end

    # @param datetime [DateTime]
    # @param default [String] a string to return if time is nil.
    # @return [String] html_safe datetime presentation
    def time_ago(datetime, default: '-', html_options: {})
      return content_tag :time, default if datetime.nil?
      html_options = html_options.dup
      is_current_year = datetime.year == Time.current.year
      if datetime > 4.days.ago
        content = t 'thredded.time_ago', time: time_ago_in_words(datetime)
        html_options['data-time-ago'] = true unless html_options.key?('data-time-ago')
      else
        content = I18n.l(datetime.to_date,
                         format: (is_current_year ? :short : :long))
      end
      html_options[:title] = I18n.l(datetime) unless html_options.key?(:title)
      time_tag datetime, content, html_options
    end

    # @param posts [Thredded::PostsPageView, Array<Thredded::PostView>]
    # @param partial [String]
    # @param content_partial [String]
    def render_posts(posts, partial: 'thredded/posts/post', content_partial: 'thredded/posts/content', locals: {})
      posts_with_contents = render_collection_to_strings_with_cache(
        partial: content_partial, collection: posts, as: :post, expires_in: 1.week
      )
      render partial: partial, collection: posts_with_contents, as: :post_and_content, locals: locals
    end

    def paginate(collection, args = {})
      super(collection, args.reverse_merge(views_prefix: 'thredded'))
    end

    # @param topic [BaseTopicView]
    # @return [Array<String>]
    def topic_css_classes(topic)
      [
        *topic.states.map { |s| "thredded--topic-#{s}" },
        *(topic.categories.map { |c| "thredded--topic-category-#{c.name}" } if topic.respond_to?(:categories)),
        *('thredded--private-topic' if topic.is_a?(Thredded::PrivateTopicView))
      ]
    end

    # @param follow_reason ['manual', 'posted', 'mentioned', 'auto', nil]
    def topic_follow_reason_text(follow_reason)
      if follow_reason
        # rubocop:disable Metrics/LineLength
        # i18n-tasks-use t('thredded.topics.following.manual') t('thredded.topics.following.posted') t('thredded.topics.following.mentioned') t('thredded.topics.following.auto')
        # rubocop:enable Metrics/LineLength
        t("thredded.topics.following.#{follow_reason}")
      else
        t('thredded.topics.not_following')
      end
    end

    def posts_pending_moderation_count
      @posts_pending_moderation_count ||= begin
        scope = Thredded::Post.pending_moderation
        moderatable_messageboards = thredded_current_user.thredded_can_moderate_messageboards
        unless moderatable_messageboards == Thredded::Messageboard.all
          scope = scope.where(messageboard_id: moderatable_messageboards.pluck(:id))
        end
        scope.count
      end
    end
  end
end
