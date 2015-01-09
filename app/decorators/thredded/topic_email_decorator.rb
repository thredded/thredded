module Thredded
  class TopicEmailDecorator
    def initialize(topic)
      @topic = topic
    end

    def smtp_api_tag(tag)
      %({"category": ["thredded_#{topic.messageboard.name}","#{tag}"]})
    end

    def subject
      "#{Thredded.email_outgoing_prefix} #{topic.title}"
    end

    def reply_to
      Thredded.email_reply_to.call(topic)
    end

    def no_reply
      Thredded.email_from
    end

    protected

    attr_reader :topic
  end
end
