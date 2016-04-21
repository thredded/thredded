# frozen_string_literal: true
module Thredded
  # A view model for TopicCommon.
  class PrivateTopicView < BaseTopicView
    def edit_path
      Thredded::UrlsHelper.edit_private_topic_path(@topic)
    end
  end
end
