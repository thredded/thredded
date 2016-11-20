# frozen_string_literal: true
module Thredded
  # A view model for a page of BaseTopicViews.
  class PrivateTopicsPageView
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
    def initialize(user, topics_page_scope)
      @topics_page_scope = topics_page_scope
      @topic_views = @topics_page_scope.with_read_states(user).map do |(topic, read_state)|
        Thredded::PrivateTopicView.new(topic, read_state, Pundit.policy!(user, topic))
      end
    end
  end
end
