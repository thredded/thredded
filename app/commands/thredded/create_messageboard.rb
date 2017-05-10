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
      Messageboard.transaction do
        fail ActiveRecord::Rollback unless @messageboard.save
        topic = Topic.create!(
          messageboard: @messageboard,
          user: @user,
          title: first_topic_title
        )
        Post.create!(
          messageboard: @messageboard,
          user: @user,
          postable: topic,
          content: first_post_content
        )
        true
      end
    end

    def first_topic_title
      "Welcome to your messageboard's very first thread"
    end

    def first_post_content
      <<-MARKDOWN
There's not a whole lot here for now.

These forums are powered by [Thredded](https://github.com/thredded/thredded) v#{Thredded::VERSION}.
You can contact the Thredded team via the [Thredded chat room](https://gitter.im/thredded/thredded).
Please let us know that you are using Thredded by tweeting [@thredded](https://twitter.com/thredded)!
      MARKDOWN
    end
  end
end
