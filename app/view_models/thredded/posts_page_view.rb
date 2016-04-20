# frozen_string_literal: true
require_dependency 'thredded/post_view'
module Thredded
  # A view model for a page of PostViews.
  class PostsPageView
    delegate :to_ary,
             to: :@post_views
    delegate :total_pages,
             :current_page,
             :limit_value,
             to: :@page_scope

    # @param user [Thredded.user_class] the user who is viewing the posts page
    # @param page_scope [ActiveRecord::Relation<Thredded::PostCommon>]
    def initialize(user, page_scope)
      @page_scope = page_scope
      @post_views = page_scope.map { |post| PostView.new(post, Pundit.policy!(user, post)) }
    end
  end
end
