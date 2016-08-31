# frozen_string_literal: true
module Thredded
  module ApplicationHelper
    include ::Thredded::UrlsHelper

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
      if user.to_s.include?(' ')
        %(@"#{user}")
      else
        "@#{user}"
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
