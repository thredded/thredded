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
      @post_views      = paginated_scope.map do |post|
        Thredded::PostView.new(post, Pundit.policy!(user, post), topic_view: topic_view)
      end
    end
  end
end
