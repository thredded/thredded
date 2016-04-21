# frozen_string_literal: true
require_dependency 'thredded/post_view'
require_dependency 'thredded/topic_view'
require_dependency 'thredded/private_topic_view'
module Thredded
  # A view model for a page of PostViews.
  class PostsPageView
    delegate :to_ary,
             to: :@topic_views
    delegate :total_pages,
             :current_page,
             :limit_value,
             to: :@topics_page_scope

    # @return [Thredded::BaseTopicView]
    attr_reader :topic

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param topic [Thredded::TopicCommon]
    # @param posts_page_scope [ActiveRecord::Relation<Thredded::PostCommon>]
    def initialize(user, topic, posts_page_scope)
      @topics_page_scope = posts_page_scope
      @topic_views = posts_page_scope.map { |post| PostView.new(post, Pundit.policy!(user, post)) }
      @topic = "#{posts_page_scope.reflect_on_association(:postable).klass}View".constantize.from_user(topic, user)
    end
  end
end
