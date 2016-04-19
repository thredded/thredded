# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe UserTopicDecorator, 'delegated methods' do
    it 'responds to topic decorator methods' do
      topic = create(:topic, with_posts: 2)
      user = create(:user)
      decorator = UserTopicDecorator.new(topic, user)

      expect(decorator).to respond_to(:to_model)
    end
  end

  describe UserTopicDecorator, '.decorate_all' do
    it 'decorates all topics' do
      topics = create_list(:topic, 2)
      user = create(:user)

      decorator = UserTopicDecorator.decorate_all(user, Topic.where(id: topics))
      expect(decorator.size).to eq(2)
    end
  end

  describe UserTopicDecorator, '#read?' do
    it 'is true if the posts counts match' do
      topic = create(:topic, with_posts: 2)
      user = create(:user)
      create(
        :user_topic_read_state,
        postable: topic,
        user: user,
        read_at: topic.updated_at
      )
      decorator = UserTopicDecorator.new(topic, user)

      expect(decorator.read?).to eq true
    end

    it 'is false if the posts counts match' do
      topic = create(:topic, with_posts: 4)
      user = create(:user)
      create(
        :user_topic_read_state,
        postable: topic,
        user: user,
        read_at: topic.posts.first.updated_at - 1.day
      )
      decorator = UserTopicDecorator.new(topic, user)

      expect(decorator.read?).to eq false
    end

    it 'is false if we have a null user' do
      topic = create(:topic, with_posts: 2)
      user = nil
      decorator = UserTopicDecorator.new(topic, user)

      expect(decorator.read?).to eq false
    end
  end

  describe UserTopicDecorator, '#farthest_page' do
    it 'returns the farthest page a user has gotten to' do
      topic = create(:topic, with_posts: 2)
      user = create(:user)
      create(
        :user_topic_read_state,
        postable: topic,
        user: user,
        read_at: topic.posts.last.updated_at,
        page: 4
      )
      decorator = UserTopicDecorator.new(topic, user)

      expect(decorator.farthest_page).to eq 4
    end

    it 'defaults to page 1 with null users' do
      topic = create(:topic, with_posts: 2)
      user = nil
      decorator = UserTopicDecorator.new(topic, user)

      expect(decorator.farthest_page).to eq 1
    end
  end

  describe UserTopicDecorator, '#css_class' do
    it 'prepends a read class to a topic' do
      topic = create(:topic, :locked, :sticky, with_posts: 2)
      user = create(:user)
      create(
        :user_topic_read_state,
        postable: topic,
        user: user,
        read_at: topic.posts.last.updated_at,
        page: 4
      )
      decorator = UserTopicDecorator.new(topic, user)
      expect(decorator.css_class).to eq 'thredded--topic--read thredded--topic--locked thredded--topic--sticky'
    end

    it 'prepends a unread class to a topic' do
      topic = create(:topic, :locked, :sticky, with_posts: 2)
      user = create(:user)
      create(
        :user_topic_read_state,
        postable: topic,
        user: user,
        read_at: topic.posts.first.updated_at - 1.day,
        page: 4
      )
      decorator = UserTopicDecorator.new(topic, user)
      expect(decorator.css_class).to eq 'thredded--topic--unread thredded--topic--locked thredded--topic--sticky'
    end
  end
end
