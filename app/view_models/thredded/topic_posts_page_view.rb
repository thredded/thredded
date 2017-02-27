# frozen_string_literal: true
module Thredded
  # A view model for a page of PostViews of a Topic.
  class TopicPostsPageView < Thredded::PostsPageView
    # @return [Thredded::BaseTopicView]
    attr_reader :topic

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param topic [Thredded::TopicCommon]
    # @param paginated_scope [ActiveRecord::Relation<Thredded::PostCommon>]
    def initialize(user, topic, paginated_scope)
      @topic = "#{paginated_scope.reflect_on_association(:postable).klass}View".constantize.from_user(topic, user)
      super(user, paginated_scope, topic_view: @topic)
    end
  end
end
