# frozen_string_literal: true
module Thredded
  class TopicPreviewsController < Thredded::ApplicationController
    include Thredded::NewTopicParams
    include Thredded::RenderPreview

    def preview
      form = TopicForm.new(new_topic_params)
      @post = form.post
      @post.postable = form.topic
      render_preview
    end
  end
end
