# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe UserTopicReadState, '#post_read?(post)' do
    let(:read_state) { create(:user_topic_read_state, read_at: 1.day.ago) }

    it 'is true when post.created_at > read_at' do
      post = create(:post, created_at: 2.days.ago)
      expect(read_state).to be_post_read(post)
    end

    it 'is true when post.created_at = read_at' do
      post = create(:post, created_at: read_state.read_at)
      expect(read_state).to be_post_read(post)
    end

    it 'is false when post.created_at < read_at' do
      post = create(:post, created_at: 1.minute.ago)
      expect(read_state).not_to be_post_read(post)
    end
  end

  describe UserTopicReadState, '.include_first_unread' do
    let(:topic) { create(:topic, with_posts: 5) }
    let(:posts) { topic.posts.to_a.sort_by(&:created_at) }

    it 'returns the first unread post page and the last read page' do
      create(:user_topic_read_state, postable: topic, read_at: posts[1].created_at)
      expect(UserTopicReadState.with_page_info(posts_per_page: 3).to_a)
        .to(contain_exactly(have_attributes(first_unread_post_page: 1, last_read_post_page: 1)))
      expect(UserTopicReadState.with_page_info(posts_per_page: 2).to_a)
        .to(contain_exactly(have_attributes(first_unread_post_page: 2, last_read_post_page: 1)))
      expect(UserTopicReadState.with_page_info(posts_per_page: 1).to_a)
        .to(contain_exactly(have_attributes(first_unread_post_page: 3, last_read_post_page: 2)))
    end

    it 'page info when there are no unread posts' do
      create(:user_topic_read_state, postable: topic, read_at: posts[-1].created_at)
      expect(UserTopicReadState.with_page_info(posts_per_page: 3).to_a)
        .to(contain_exactly(have_attributes(first_unread_post_page: nil, last_read_post_page: 2)))
    end
  end

  describe UserTopicReadState, '.touch!' do
    let(:user) { create(:user) }
    let(:messageboard) { create(:messageboard) }

    it 'creates a new state if none exists' do
      topic = create(:topic, with_posts: 3, messageboard: messageboard)
      expect { UserTopicReadState.touch!(user.id, topic.posts[1]) }.to(change(UserTopicReadState, :count).by(1))
      expect(UserTopicReadState.last).to(
        have_attributes(
          user_id: user.id,
          postable_id: topic.id,
          messageboard_id: messageboard.id,
          read_at: topic.posts[1].created_at,
          read_posts_count: 2,
          unread_posts_count: 1,
        )
      )
    end

    it 'updates the existing state if it already exists' do
      topic = create(:topic, with_posts: 3, messageboard: messageboard)
      UserTopicReadState.touch!(user.id, topic.posts[0])
      expect { UserTopicReadState.touch!(user.id, topic.posts[1]) }.not_to(change(UserTopicReadState, :count))
      expect(UserTopicReadState.last).to(
        have_attributes(
          id: UserTopicReadState.last.id,
          user_id: user.id,
          postable_id: topic.id,
          messageboard_id: messageboard.id,
          read_at: topic.posts[1].created_at,
          read_posts_count: 2,
          unread_posts_count: 1,
        )
      )
    end
  end

  describe NullUserTopicReadState, '#post_read?(post)' do
    it 'is false' do
      post = create(:post)
      null_user_topic_read_state = NullUserTopicReadState.new
      expect(null_user_topic_read_state).not_to be_post_read(post)
    end
  end
end
