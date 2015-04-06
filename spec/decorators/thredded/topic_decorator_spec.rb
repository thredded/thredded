require 'spec_helper'

module Thredded
  describe TopicDecorator, '#user_link' do
    after do
      Thredded.user_path = nil
    end

    it 'links to a valid user' do
      Thredded.user_path = ->(user) { "/i_am/#{user}" }
      user = create(:user, name: 'joel')
      topic = create(:topic, user: user)
      create(
        :user_topic_read,
        topic: topic,
        user: user,
      )
      decorator = TopicDecorator.new(topic)

      expect(decorator.user_link).to eq "<a href='/i_am/joel'>joel</a>"
    end

    it 'links to nowhere for a null user' do
      topic = build_stubbed(:topic, user: nil)
      decorator = TopicDecorator.new(topic)

      expect(decorator.user_link).to eq 'Anonymous User'
    end
  end

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
      Thredded.user_path = ->(user) { "/hi/#{user}" }
      user = build_stubbed(:user, name: 'joel')
      topic = build_stubbed(:topic, last_user: user)
      decorated_topic = TopicDecorator.new(topic)

      expect(decorated_topic.last_user_link).to eq "<a href='/hi/joel'>joel</a>"
    end
  end

  describe TopicDecorator, '#css_class' do
    let(:user) { build_stubbed(:user) }

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
