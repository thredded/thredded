# frozen_string_literal: true

module Thredded
  # Creates a new messageboard and seeds it with a topic.
  class CreateMessageboard
    # @param messageboard [Thredded::Messageboard]
    # @param user [Thredded.user_class]
    def initialize(messageboard, user)
      @messageboard = messageboard
      @user = user
    end

    # @return [boolean] true if the messageboard was created and seeded with a topic successfully.
    def run
      Thredded::Messageboard.transaction do
        fail ActiveRecord::Rollback unless @messageboard.save
        topic = Thredded::Topic.create!(
          messageboard: @messageboard,
          user: @user,
          title: first_topic_title
        )
        Thredded::Post.create!(
          messageboard: @messageboard,
          user: @user,
          postable: topic,
          content: first_post_content
        )
        true
      end
    end

    def first_topic_title
      I18n.t('thredded.topics.first_of_messageboard.title')
    end

    def first_post_content
      <<-MARKDOWN
#{I18n.t('thredded.posts.first_of_messageboard.content', thredded_version: Thredded::VERSION)}
      MARKDOWN
    end
  end
end
