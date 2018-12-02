# frozen_string_literal: true

module Thredded
  class PostPreviewsController < Thredded::ApplicationController
    include Thredded::RenderPreview

    before_action :thredded_require_login!
    after_action :verify_authorized

    # Preview a new post
    def preview
      @post = Thredded::Post.new(post_params)
      @post.postable = Thredded::Topic.friendly_find!(params[:topic_id])
      authorize @post, :create?
      render_preview
    end

    # Preview an update to an existing post
    def update
      @post = Thredded::Post.find!(params[:post_id])
      authorize @post, :update?
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
