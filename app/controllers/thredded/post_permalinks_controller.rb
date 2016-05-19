# frozen_string_literal: true
module Thredded
  class PostPermalinksController < ApplicationController
    def show
      post = Post.find(params[:id])
      authorize post, :read?
      redirect_to post_url(post), status: :found
    end
  end
end
