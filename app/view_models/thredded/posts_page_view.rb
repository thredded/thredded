# frozen_string_literal: true
require_dependency 'thredded/post_view'
require_dependency 'thredded/topic_view'
require_dependency 'thredded/private_topic_view'
module Thredded
  # A view model for a page of PostViews.
  class PostsPageView
    delegate :to_ary,
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
    def initialize(user, paginated_scope)
      @paginated_scope = paginated_scope
      @post_views      = paginated_scope.map { |post| PostView.new(post, Pundit.policy!(user, post)) }
    end
  end
end
