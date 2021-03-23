# frozen_string_literal: true

module Thredded
  # @api private
  module NewTopicParams
    protected

    def new_topic_params
      params[:topic][:type] ||= 'Thredded::TopicDefault'
      params
        .fetch(:topic, {})
        .permit(:title, :locked, :sticky, :content, :video_url, :type, :badge_id, category_ids: [])
        .merge(
          messageboard: messageboard,
          user: thredded_current_user,
        )
    end
  end
end
