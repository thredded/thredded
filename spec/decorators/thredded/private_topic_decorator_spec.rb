require 'spec_helper'

module Thredded
  describe PrivateTopicDecorator, '#css_class' do
    it 'builds a class with private if the topic is private' do
      topic = build_stubbed(:private_topic)
      decorated_topic = PrivateTopicDecorator.new(topic)

      expect(decorated_topic.css_class).to eq 'private_topic'
    end
  end
end
