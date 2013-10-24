require 'spec_helper'

module Thredded
  describe TopicDecorator, '#slug' do
    it 'uses the id if slug is nil' do
      topic = build_stubbed(:topic, slug: nil)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.slug).to eq topic.id
    end

    it 'uses the slug if it is there' do
      topic = build_stubbed(:topic, slug: 'hi-topic')
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.slug).to eq 'hi-topic'
    end
  end

  describe TopicDecorator, '#css_class' do
    let(:user){ build_stubbed(:user) }

    it 'builds a class with locked if the topic is locked' do
      topic = build_stubbed(:topic, locked: true)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include 'locked'
    end

    it 'builds a class with sticky if the topic is sticky' do
      topic = build_stubbed(:topic, sticky: true)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include 'sticky'
    end

    it 'builds a class with private if the topic is private' do
      topic = build_stubbed(:private_topic)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include 'private'
    end

    it 'returns nothing if plain vanilla topic' do
      topic = build_stubbed(:topic)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include ''
    end

    it 'returns string with several topic states' do
      topic = build_stubbed(:topic, sticky: true, locked: true)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.css_class).to include 'locked sticky'
    end
  end
end
