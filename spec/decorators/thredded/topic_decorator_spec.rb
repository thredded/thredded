require 'spec_helper'

module Thredded
  describe TopicDecorator, '#css_class' do
    let(:user) { build_stubbed(:user) }

    it 'builds a class with locked if the topic is locked' do
      topic = build_stubbed(:topic, locked: true)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include 'thredded--topic--locked'
    end

    it 'builds a class with sticky if the topic is sticky' do
      topic = build_stubbed(:topic, sticky: true)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include 'thredded--topic--sticky'
    end

    it 'returns nothing if plain vanilla topic' do
      topic = build_stubbed(:topic)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include ''
    end

    it 'returns string with several topic states' do
      topic = build_stubbed(:topic, sticky: true, locked: true)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include 'thredded--topic--locked thredded--topic--sticky'
    end
  end
end
