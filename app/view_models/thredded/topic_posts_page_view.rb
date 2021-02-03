# frozen_string_literal: true

module Thredded
  # A view model for a page of PostViews of a Topic.
  class TopicPostsPageView < Thredded::PostsPageView
    # @return [Thredded::BaseTopicView]
    attr_reader :topic, :id, :post_views, :post_view_ids, :topic_id, :category_ids

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param topic [Thredded::TopicCommon]
    # @param paginated_scope [ActiveRecord::Relation<Thredded::PostCommon>]
    def initialize(user, topic, paginated_scope)
      @paginated_scope = paginated_scope
      @topic = "#{paginated_scope.reflect_on_association(:postable).klass}View".constantize.from_user(topic, user)
      prev_read = false
      @topic_id = @topic&.topic.id
      @id = nil
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
      @post_view_ids = @post_views.map { |post_view| post_view.post.id }
    end
  end
end
