# frozen_string_literal: true
module Thredded
  module ApplicationHelper
    include ::Thredded::UrlsHelper

    def thredded_container_data
      {
        'thredded-page-id' => content_for(:thredded_page_id),
        'thredded-root-url' => thredded.root_path
      }
    end

    def thredded_container_classes
      ['thredded--main-container', content_for(:thredded_page_id)].tap do |classes|
        classes << 'thredded--is-moderator' if moderatable_messageboards_ids
      end
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
    def time_ago(datetime, default: '-')
      timeago_tag datetime,
                  lang: I18n.locale.to_s.downcase,
                  format: -> (t, _opts) { t.year == Time.current.year ? :short : :long },
                  nojs: true,
                  default: default
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

    # @param follow_reason ['manual', 'posted', 'mentioned', nil]
    def topic_follow_reason_text(follow_reason)
      if follow_reason
        # rubocop:disable Metrics/LineLength
        # i18n-tasks-use t('thredded.topics.following.manual') t('thredded.topics.following.posted') t('thredded.topics.following.mentioned')
        # rubocop:enable Metrics/LineLength
        t("thredded.topics.following.#{follow_reason}")
      else
        t('thredded.topics.not_following')
      end
    end

    def unread_private_topics_count
      @unread_private_topics_count ||=
        if signed_in?
          Thredded::PrivateTopic
            .for_user(thredded_current_user)
            .unread(thredded_current_user)
            .count
        else
          0
        end
    end

    def moderatable_messageboards_ids
      @moderatable_messageboards_ids ||=
        thredded_current_user.thredded_can_moderate_messageboards.pluck(:id)
    end

    def posts_pending_moderation_count
      @posts_pending_moderation_count ||=
        Thredded::Post.where(messageboard_id: moderatable_messageboards_ids).pending_moderation.count
    end
  end
end
