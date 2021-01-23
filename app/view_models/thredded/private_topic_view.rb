# frozen_string_literal: true

module Thredded
  # A view model for PrivateTopic.
  class PrivateTopicView < Thredded::BaseTopicView
    attr_reader :user_names, :content
    delegate :users, to: :@topic

    def edit_path
      Thredded::UrlsHelper.edit_private_topic_path(@topic)
    end

    def self.from_user(topic, user)
      read_state = if user && !user.thredded_anonymous?
                     Thredded::UserPrivateTopicReadState
                       .find_by(user_id: user.id, postable_id: topic.id)
                   end
      new(topic, read_state, Pundit.policy!(user, topic))
    end
  end
end
