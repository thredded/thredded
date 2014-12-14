require 'spec_helper'

module Thredded
  describe PrivateTopicDecorator, '#css_class' do
    it 'builds a class with private if the topic is private' do
      topic = build_stubbed(:private_topic)
      decorated_topic = PrivateTopicDecorator.new(topic)

      expect(decorated_topic.css_class).to eq 'private_topic'
    end
  end

  describe PrivateTopicDecorator, '#last_user_link' do
    after do
      Thredded.user_path = nil
    end

    it 'returns link to root if config is not set' do
      user = build_stubbed(:user, name: 'joel')
      topic = build_stubbed(:private_topic, last_user: user)
      decorated_topic = PrivateTopicDecorator.new(topic)

      expect(decorated_topic.last_user_link).to eq '<a href="/">joel</a>'
    end

    it 'returns link to user if config is set' do
      Thredded.user_path = ->(user) { "/hi/#{user}" }
      user = build_stubbed(:user, name: 'joel')
      topic = build_stubbed(:private_topic, last_user: user)
      decorated_topic = PrivateTopicDecorator.new(topic)

      expect(decorated_topic.last_user_link).to eq '<a href="/hi/joel">joel</a>'
    end
  end
end
