# frozen_string_literal: true
require_dependency 'thredded/topic_view'
module Thredded
  # A view model for a page of BaseTopicViews.
  class TopicsPageView
    delegate :to_ary,
             :blank?,
             :empty?,
             to: :@topic_views
    delegate :total_pages,
             :current_page,
             :limit_value,
             to: :@topics_page_scope

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param topics_page_scope [ActiveRecord::Relation<Thredded::Topic>]
    # @param topic_view_class [Class] view_model for topic instances
    def initialize(user, topics_page_scope, topic_view_class: TopicView)
      @topics_page_scope = refine_scope(topics_page_scope)
      @topic_views = @topics_page_scope.with_read_and_follow_states(user).map do |(topic, read_state, follow)|
        topic_view_class.new(topic, read_state, follow, Pundit.policy!(user, topic))
      end
    end

    protected

    def refine_scope(topics_page_scope)
      scope = topics_page_scope.includes(:categories, :last_user, :user)
      if Thredded.show_topic_followers
        scope.includes(:followers)
      else
        scope
      end
    end
  end
end
