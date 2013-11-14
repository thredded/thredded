require 'spec_helper'

module Thredded
  describe TopicDecorator, '#last_user_link' do
    after do
      Thredded.user_path = nil
    end

    it 'returns "Anonymous" if nothing is there' do
      topic = build_stubbed(:topic, last_user: nil)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.last_user_link).to eq 'Anonymous User'
    end

    it 'returns link to root if config is not set' do
      user = build_stubbed(:user, name: 'joel')
      topic = build_stubbed(:topic, last_user: user)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.last_user_link).to eq "<a href='/'>joel</a>"
    end

    it 'returns link to user if config is set' do
      Thredded.user_path = ->(user){ "/hi/#{user}" }
      user = build_stubbed(:user, name: 'joel')
      topic = build_stubbed(:topic, last_user: user)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.last_user_link).to eq "<a href='/hi/joel'>joel</a>"
    end
  end

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
