# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe AutofollowMentionedUsers, '#autofollowers' do
    before do
      @sam = create(:user, name: 'sam')
      @joel = create(:user, name: 'joel', email: 'joel@example.com')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @post = build(:post, user: @sam, content: 'hey @joel and @john. - @sam')
      @messageboard = @post.messageboard
    end

    it 'respects global notification preferences' do
      create(:user_preference, user: @joel, notify_on_mention: true)
      create(:user_messageboard_preference, user: @joel, notify_on_mention: false, messageboard: @messageboard)
      create(:user_preference, user: @john, notify_on_mention: false)
      create(:user_messageboard_preference, user: @john, notify_on_mention: true, messageboard: @messageboard)

      expect(AutofollowMentionedUsers.new(@post).autofollowers).to be_empty
    end

    it 'returns 2 users mentioned, not including post author' do
      command = AutofollowMentionedUsers.new(@post)
      autofollowable_mentioned_users = command.autofollowers
      expect(autofollowable_mentioned_users).to match_array([@joel, @john])
    end

    it 'does not return users that set their preference to "no @ notifications"' do
      create(:user_messageboard_preference, notify_on_mention: false, user: @joel, messageboard: @post.messageboard)
      command = AutofollowMentionedUsers.new(@post)
      users = command.autofollowers

      expect(users).not_to include(@joel)
    end
  end

  describe AutofollowMentionedUsers, '#run' do
    before do
      sam = create(:user, name: 'sam')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @post = build_post_by(sam)
    end

    it 'adds follows for the users mentioned' do
      expect { AutofollowMentionedUsers.new(@post).run }
        .to change { @post.postable.user_follows.reload.count }.from(0).to(1)
    end

    it 'does add follows for users already following' do
      create(:user_topic_follow, user: @john, topic: @post.postable)
      expect { AutofollowMentionedUsers.new(@post).run }
        .not_to change { @post.postable.user_follows.reload.count }.from(1)
    end

    def build_post_by(user)
      messageboard = create(:messageboard)
      build(:post, user: user, content: 'hi @john', messageboard: messageboard)
    end
  end
end
