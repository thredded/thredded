# frozen_string_literal: true

module Thredded
  # A view model for a page of PostViews of a Topic.
  class TopicPostsPageView
    delegate :each,
             :each_with_index,
             :map,
             :size,
             :to_a,
             :to_ary,
             :present?,
             to: :@post_views
    delegate :total_pages,
             :current_page,
             :limit_value,
             to: :@posts_paginator

    # @return [Thredded::BaseTopicView]
    attr_reader :topic

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param topic [Thredded::TopicCommon]
    # @param paginated_scope [ActiveRecord::Relation<Thredded::PostCommon>] a kaminari-decorated ".page" scope
    def initialize(user, topic, paginated_scope)
      @posts_paginator = paginated_scope
      @topic = "#{paginated_scope.reflect_on_association(:postable).klass}View".constantize.from_user(topic, user)
      prev_read = false
      @post_views = paginated_scope.map.with_index do |post, i|
        post_read = @topic.post_read?(post)
        post_view = Thredded::PostView.new(
          post, Pundit.policy!(user, post),
          topic_view: @topic,
          first_in_page: i.zero?,
          first_unread_in_page: !post_read && prev_read
        )
        prev_read = post_read
        post_view
      end
    end
  end
end
