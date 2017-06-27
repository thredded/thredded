# frozen_string_literal: true

module Thredded
  class PostPreviewsController < Thredded::ApplicationController
    include Thredded::RenderPreview

    # Preview a new post
    def preview
      @post = Thredded::Post.new(post_params)
      @post.postable = Thredded::Topic.friendly_find!(params[:topic_id])
      render_preview
    end

    # Preview an update to an existing post
    def update
      @post = Thredded::Post.find(params[:post_id])
      @post.assign_attributes(post_params)
      render_preview
    end

    private

    def post_params
      params.require(:post)
        .permit(:content)
        .merge(user: thredded_current_user, messageboard: messageboard)
    end
  end
end
