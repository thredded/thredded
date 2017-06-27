# frozen_string_literal: true

module Thredded
  class PrivatePostPreviewsController < Thredded::ApplicationController
    include Thredded::RenderPreview

    # Preview a new post
    def preview
      @private_post = Thredded::PrivatePost.new(private_post_params)
      @private_post.postable = Thredded::PrivateTopic.friendly_find!(params[:private_topic_id])
      render_preview
    end

    # Preview an update to an existing post
    def update
      @private_post = Thredded::PrivatePost.find(params[:private_post_id])
      @private_post.assign_attributes(private_post_params)
      render_preview
    end

    private

    def private_post_params
      params.require(:post)
        .permit(:content)
        .merge(user: thredded_current_user)
    end
  end
end
