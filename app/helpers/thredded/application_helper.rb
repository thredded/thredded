module Thredded
  module ApplicationHelper
    # Render the page container with the supplied block as content.
    def thredded_page(&block)
      # enable the host app to easily check whether a thredded view is being rendered:
      content_for :thredded, true
      content_for :thredded_page_content, &block
      render partial: 'thredded/shared/page'
    end

    # @param user [Thredded.user_class, Thredded::NullUser]
    # @return [String] path to the user as specified by {Thredded.user_path}
    def user_path(user)
      Thredded.user_path(self, user)
    end

    # @param user [Thredded.user_class, Thredded::NullUser]
    # @return [String] html_safe link to the user
    def user_link(user)
      render partial: 'thredded/users/link', locals: { user: user }
    end

    # @param datetime [DateTime]
    # @return [String] html_safe datetime presentation
    def time_ago(datetime)
      render partial: 'thredded/shared/time_ago', locals: { datetime: datetime }
    end

    def paginate(collection, args = {})
      super(collection, args.reverse_merge(views_prefix: 'thredded'))
    end

    def edit_post_path(post)
      if post.private_topic_post?
        edit_private_topic_private_post_path(post.postable, post)
      else
        edit_messageboard_topic_post_path(messageboard, post.postable, post)
      end
    end

    # @param topic [UserTopicDecorator, UserPrivateTopicDecorator]
    # @return [String] path to the latest unread page of the given topic.
    def topic_path(topic, params = {})
      if topic.private?
        # TODO: this should actually pass the latest read page.
        private_topic_path(
          topic.slug,
          **params
        )
      else
        # TODO: farthest_page always returns 1, investigate.
        params[:page] ||= topic.farthest_page
        params[:page] = nil if params[:page] == 1
        messageboard_topic_path(
          topic.messageboard.slug,
          topic.slug,
          **params
        )
      end
    end
  end
end
