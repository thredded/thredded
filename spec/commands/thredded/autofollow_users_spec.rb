# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe AutofollowUsers, '#autofollowers' do
    before do
      @sam = create(:user, name: 'sam')
      @joel = create(:user, name: 'joel', email: 'joel@example.com')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @post = build(:post, user: @sam, content: 'hey @joel and @john. - @sam')
      @messageboard = @post.messageboard
    end

    it 'respects global notification preferences' do
      create(:user_preference, user: @joel, follow_topics_on_mention: true)
      create(:user_messageboard_preference, user: @joel, follow_topics_on_mention: false, messageboard: @messageboard)
      create(:user_preference, user: @john, follow_topics_on_mention: false)
      create(:user_messageboard_preference, user: @john, follow_topics_on_mention: true, messageboard: @messageboard)

      expect(AutofollowUsers.new(@post).autofollowers).to be_empty
    end

    it 'returns 2 users mentioned, not including post author' do
      command = AutofollowUsers.new(@post)
      autofollowable_mentioned_users = command.autofollowers
      expect(autofollowable_mentioned_users).to match_array([@joel, @john])
    end

    it 'includes users who have message board auto-follow set' do
      @sara = create(:user, name: 'sara', email: 'sara@example.com')
      create(:user_preference, user: @sara, auto_follow_topics: true)
      create(:user_messageboard_preference, user: @sara, auto_follow_topics: true, messageboard: @messageboard)

      command = AutofollowUsers.new(@post)
      autofollowable_users = command.autofollowers
      expect(autofollowable_users).to include(@sara)
    end

    it 'does not include users who have disabled auto-follow on this board' do
      @sara = create(:user, name: 'sara', email: 'sara@example.com')
      create(:user_preference, user: @sara, auto_follow_topics: true)
      create(:user_messageboard_preference, user: @sara, auto_follow_topics: false, messageboard: @messageboard)

      command = AutofollowUsers.new(@post)
      autofollowable_users = command.autofollowers
      expect(autofollowable_users).to_not include(@sara)
    end

    it 'does not return users that set their preference to "no @ notifications"' do
      create(
        :user_messageboard_preference,
        follow_topics_on_mention: false,
        user: @joel,
        messageboard: @post.messageboard
      )
      command = AutofollowUsers.new(@post)
      users = command.autofollowers

      expect(users).not_to include(@joel)
    end
  end

  describe AutofollowUsers, '#run' do
    before do
      sam = create(:user, name: 'sam')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @post = build_post_by(sam)
    end

    it 'adds follows for the users mentioned' do
      expect { AutofollowUsers.new(@post).run }
        .to change { @post.postable.user_follows.reload.count }.from(0).to(1)
    end

    it 'does add follows for users already following' do
      create(:user_topic_follow, user: @john, topic: @post.postable)
      expect { AutofollowUsers.new(@post).run }
        .not_to change { @post.postable.user_follows.reload.count }.from(1)
    end

    def build_post_by(user)
      messageboard = create(:messageboard)
      build(:post, user: user, content: 'hi @john', messageboard: messageboard)
    end
  end
end
