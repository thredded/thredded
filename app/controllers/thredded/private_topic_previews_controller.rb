# frozen_string_literal: true

module Thredded
  class PrivateTopicPreviewsController < Thredded::ApplicationController
    include Thredded::NewPrivateTopicParams
    include Thredded::RenderPreview

    def preview
      form = Thredded::PrivateTopicForm.new(new_private_topic_params)
      @private_post = form.post
      @private_post.postable = form.private_topic
      render_preview
    end
  end
end
