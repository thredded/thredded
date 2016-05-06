# frozen_string_literal: true
require_dependency 'thredded/topic_view'
require_dependency 'thredded/private_topic_view'
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
    def initialize(user, topics_page_scope)
      @topics_page_scope = topics_page_scope
      topic_view_class = "#{topics_page_scope.klass}View".constantize
      @topic_views = @topics_page_scope.with_read_states(user).map do |(topic, read_state)|
        topic_view_class.new(topic, read_state, Pundit.policy!(user, topic))
      end
    end

    def sort_filter_options
      Thredded::Topic::ORDER_OPTS.map do |opt|
        [
          I18n.t(opt, scope: 'thredded.topics.sort_filter.options'),
          opt,
        ]
      end
    end
  end
end
