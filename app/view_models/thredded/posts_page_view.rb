# frozen_string_literal: true

module Thredded
  # A view model for a page of PostViews.
  class PostsPageView
    delegate :each,
             :each_with_index,
             :map,
             :size,
             :to_a,
             :to_ary,
             :present?,
             to: :@post_views
    delegate :total_pages,
             :current_page,
             :limit_value,
             to: :@posts_paginator

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param paginated_scope [ActiveRecord::Relation<Thredded::PostCommon>] a kaminari-decorated ".page" scope
    def initialize(user, paginated_scope)
      @posts_paginator = paginated_scope
      @post_views = paginated_scope.map do |post|
        Thredded::PostView.new(post, Pundit.policy!(user, post))
      end
    end
  end
end
