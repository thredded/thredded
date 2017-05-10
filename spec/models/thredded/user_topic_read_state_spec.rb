# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe UserTopicReadState, '#post_read?(post)' do
    let(:read_state) do
      create(:user_topic_read_state,
             postable: create(:topic),
             user: create(:user),
             read_at: 1.day.ago)
    end

    it 'is true when post.created_at > read_at' do
      post = create(:post, created_at: 2.days.ago)
      expect(read_state.post_read?(post)).to be_truthy
    end

    it 'is true when post.created_at = read_at' do
      post = create(:post, created_at: read_state.read_at)
      expect(read_state.post_read?(post)).to be_truthy
    end

    it 'is false when post.created_at < read_at' do
      post = create(:post, created_at: 1.minute.ago)
      expect(read_state.post_read?(post)).to be_falsey
    end
  end

  describe NullUserTopicReadState, '#post_read?(post)' do
    it 'is false' do
      post = create(:post)
      null_user_topic_read_state = NullUserTopicReadState.new
      expect(null_user_topic_read_state.post_read?(post)).to be_falsey
    end
  end
end
