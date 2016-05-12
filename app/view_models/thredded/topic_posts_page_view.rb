# frozen_string_literal: true
require_dependency 'thredded/posts_page_view'
module Thredded
  # A view model for a page of PostViews of a Topic.
  class TopicPostsPageView < PostsPageView
    # @return [Thredded::BaseTopicView]
    attr_reader :topic

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param topic [Thredded::TopicCommon]
    # @param paginated_scope [ActiveRecord::Relation<Thredded::PostCommon>]
    def initialize(user, topic, paginated_scope)
      super(user, paginated_scope)
      @topic = "#{paginated_scope.reflect_on_association(:postable).klass}View".constantize.from_user(topic, user)
    end
  end
end
