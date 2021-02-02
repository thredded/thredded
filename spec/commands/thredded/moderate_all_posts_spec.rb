# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe ModerateAllPosts, '.run!' do
    let(:moderator) { create(:user) }
    let(:topic) { create(:topic, with_posts: 10) }

    it "approving a user approves all topics and posts by the same user" do
      Thredded::ModerateAllPosts.run!(
        posts_scope: topic.posts,
        moderation_state: :approved,
        moderator: moderator,
        )
      topic.posts.each do |post|
        expect(post).to be_approved
      end
      topic.reload
      expect(topic).to be_approved
    end

    it "blocking a user blocks all topics and posts by the same user" do
      Thredded::ModerateAllPosts.run!(
        posts_scope: topic.posts,
        moderation_state: :blocked,
        moderator: moderator,
        )
      topic.posts.each do |post|
        expect(post).to be_blocked
      end
      topic.reload
      expect(topic).to be_blocked
    end
  end
end
