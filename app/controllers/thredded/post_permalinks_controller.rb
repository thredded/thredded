# frozen_string_literal: true

module Thredded
  class PostPermalinksController < Thredded::ApplicationController
    def show
      post = Post.find(params[:id])
      authorize post, :read?
      redirect_to post_url(post, user: thredded_current_user), status: :found
    end
  end
end
