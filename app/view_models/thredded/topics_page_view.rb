# frozen_string_literal: true

module Thredded
  # A view model for a page of BaseTopicViews.
  class TopicsPageView
    delegate :to_a,
             :to_ary,
             :blank?,
             :empty?,
             :[],
             :each,
             :each_with_index,
             :map,
             :size,
             to: :@topic_views
    delegate :total_pages,
             :current_page,
             :limit_value,
             to: :@topics_paginator

    # @param user [Thredded.user_class] the user who is viewing the topics page
    # @param topics_page_scope [ActiveRecord::Relation<Thredded::Topic>] a kaminari-decorated ".page" scope
    # @param topic_view_class [Class<TopicView>] view_model for topic instances
    def initialize(user, topics_page_scope, topic_view_class: TopicView)
      @topics_paginator = refine_scope(topics_page_scope)
      @topic_views = @topics_paginator.with_read_and_follow_states(user).map do |(topic, read_state, follow)|
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
