# frozen_string_literal: true

module Thredded
  # @api private
  module NewTopicParams
    protected

    def new_topic_params
      params
        .fetch(:topic, {})
        .permit(:title, :locked, :sticky, :content, :video_url, :type, category_ids: [])
        .merge(
          messageboard: messageboard,
          user: thredded_current_user,
        )
    end
  end
end
