# frozen_string_literal: true
module Thredded
  class TopicEmailDecorator
    # @param [Thredded::TopicCommon] topic
    def initialize(topic)
      @topic = topic
    end

    def smtp_api_tag(tag)
      %({"category": ["thredded_#{@topic.private? ? 'private_topic' : @topic.messageboard.name}","#{tag}"]})
    end

    def subject
      "#{Thredded.email_outgoing_prefix} #{@topic.title}"
    end

    def reply_to
      Thredded.email_reply_to.call(@topic)
    end

    def no_reply
      Thredded.email_from
    end
  end
end
