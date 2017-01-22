# frozen_string_literal: true
module Thredded
  # A view model for PrivateTopic.
  class PrivateTopicView < Thredded::BaseTopicView
    delegate :users, to: :@topic

    def edit_path
      Thredded::UrlsHelper.edit_private_topic_path(@topic)
    end

    def self.from_user(topic, user)
      read_state = if user && !user.thredded_anonymous?
                     UserPrivateTopicReadState
                       .find_by(user_id: user.id, postable_id: topic.id)
                   end
      new(topic, read_state, Pundit.policy!(user, topic))
    end

    def new_post_preview_path
      Thredded::UrlsHelper.preview_new_private_topic_private_post_path(@topic)
    end
  end
end
