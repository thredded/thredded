# frozen_string_literal: true

module Thredded
  class PrivateTopicPreviewsController < Thredded::ApplicationController
    include Thredded::NewPrivateTopicParams
    include Thredded::RenderPreview

    before_action :thredded_require_login!
    after_action :verify_authorized

    def preview
      form = Thredded::PrivateTopicForm.new(new_private_topic_params)
      authorize_creating form.private_topic
      @private_post = form.post
      @private_post.postable = form.private_topic
      render_preview
    end
  end
end
