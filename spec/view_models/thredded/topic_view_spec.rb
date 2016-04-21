# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe TopicView, '#css_class' do
    let(:user) { build_stubbed(:user) }

    it 'builds a class with locked if the topic is locked' do
      topic = build_stubbed(:topic, locked: true)
      topic_view = TopicView.from_user(topic, create(:user))

      expect(topic_view.states).to include :locked
    end

    it 'builds a class with sticky if the topic is sticky' do
      topic = build_stubbed(:topic, sticky: true)
      topic_view = TopicView.from_user(topic, create(:user))

      expect(topic_view.states).to include :sticky
    end

    it 'returns nothing if plain vanilla topic' do
      topic = build_stubbed(:topic)
      topic_view = TopicView.from_user(topic, create(:user))

      expect(topic_view.states).not_to include(:locked, :sticky)
    end

    it 'returns string with several topic states' do
      topic = build_stubbed(:topic, sticky: true, locked: true)
      topic_view = TopicView.from_user(topic, create(:user))

      expect(topic_view.states).to include(:locked, :sticky)
    end
  end

  describe TopicView, '#read?' do
    it 'is true if the posts counts match' do
      topic = create(:topic, with_posts: 2)
      user = create(:user)
      create(
        :user_topic_read_state,
        postable: topic,
        user: user,
        read_at: topic.updated_at
      )
      topic_view = TopicView.from_user(topic, user)

      expect(topic_view.read?).to eq true
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
      topic_view = TopicView.from_user(topic, user)

      expect(topic_view.read?).to eq false
    end

    it 'is false if we have a null user' do
      topic = create(:topic, with_posts: 2)
      user = nil
      topic_view = TopicView.from_user(topic, user)

      expect(topic_view.read?).to eq false
    end
  end

  describe TopicView, '#states' do
    it 'prepends a read state' do
      topic = create(:topic, :locked, :sticky, with_posts: 2)
      user = create(:user)
      create(
        :user_topic_read_state,
        postable: topic,
        user: user,
        read_at: topic.posts.last.updated_at,
        page: 4
      )
      topic_view = TopicView.from_user(topic, user)
      expect(topic_view.states[0]).to eq :read
    end

    it 'prepends an unread state' do
      topic = create(:topic, :locked, :sticky, with_posts: 2)
      user = create(:user)
      create(
        :user_topic_read_state,
        postable: topic,
        user: user,
        read_at: topic.posts.first.updated_at - 1.day,
        page: 4
      )
      topic_view = TopicView.from_user(topic, user)
      expect(topic_view.states[0]).to eq :unread
    end
  end
end
