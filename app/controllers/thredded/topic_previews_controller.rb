# frozen_string_literal: true

module Thredded
  class TopicPreviewsController < Thredded::ApplicationController
    include Thredded::NewTopicParams
    include Thredded::RenderPreview

    before_action :thredded_require_login!
    after_action :verify_authorized

    def preview
      form = Thredded::TopicForm.new(new_topic_params)
      authorize_creating form.topic
      @post = form.post
      @post.postable = form.topic
      render_preview
    end
  end
end
