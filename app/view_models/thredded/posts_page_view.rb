# frozen_string_literal: true

module Thredded
  # A view model for a page of PostViews.
  class PostsPageView
    delegate :to_a,
             :to_ary,
             :present?,
             to: :@post_views
    delegate :total_pages,
             :current_page,
             :limit_value,
             to: :@paginated_scope

    # @return [Thredded::BaseTopicView]
    attr_reader :topic

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param paginated_scope [ActiveRecord::Relation<Thredded::PostCommon>]
    def initialize(user, paginated_scope, topic_view: nil)
      @paginated_scope = paginated_scope
      prev_read = false
      @post_views = paginated_scope.map.with_index do |post, i|
        post_read = topic_view.post_read?(post)
        post_view = Thredded::PostView.new(
          post, Pundit.policy!(user, post),
          topic_view: topic_view,
          first_in_page: i.zero?,
          first_unread_in_page: !post_read && prev_read
        )
        prev_read = post_read
        post_view
      end
    end
  end
end
