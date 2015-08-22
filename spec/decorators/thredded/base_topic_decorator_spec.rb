require 'spec_helper'
require 'chronic'

module Thredded
  describe BaseTopicDecorator, '#slug' do
    it 'uses the id if slug is nil' do
      topic = build_stubbed(:topic, slug: nil)
      decorated_topic = BaseTopicDecorator.new(topic)

      expect(decorated_topic.slug).to eq topic.id
    end

    it 'uses the slug if it is there' do
      topic = build_stubbed(:topic, slug: 'hi-topic')
      decorated_topic = BaseTopicDecorator.new(topic)

      expect(decorated_topic.slug).to eq 'hi-topic'
    end
  end
end
