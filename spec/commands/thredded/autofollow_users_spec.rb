# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe AutofollowUsers, '#autofollowers' do
    before do
      @sam = create(:user, name: 'sam')
      @joel = create(:user, name: 'joel', email: 'joel@example.com')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @messageboard = create(:messageboard)
      @topic = build(:topic, messageboard: @messageboard, user: @sam, last_user: @sam)
      @post = build(
        :post, postable: @topic, messageboard: @messageboard, user: @sam, content: 'hey @joel and @john. - @sam'
      )
      expect(User.count).to eq(3)
    end

    context '@-mention' do
      it 'respects global `follow_topics_on_mention` notification preference' do
        create(:user_preference, user: @joel, follow_topics_on_mention: true)
        create(:user_messageboard_preference, user: @joel, follow_topics_on_mention: false, messageboard: @messageboard)
        create(:user_preference, user: @john, follow_topics_on_mention: false)
        create(:user_messageboard_preference, user: @john, follow_topics_on_mention: true, messageboard: @messageboard)
        expect(AutofollowUsers.new(@post).new_followers).to be_empty
      end

      it 'returns 2 users mentioned, not including post author' do
        expect(AutofollowUsers.new(@post).new_followers).to match(@joel => :mentioned, @john => :mentioned)
      end

      it 'does not return users that set their preference to "no @ notifications"' do
        create(
          :user_messageboard_preference,
          follow_topics_on_mention: false,
          user: @joel,
          messageboard: @post.messageboard
        )
        expect(AutofollowUsers.new(@post).new_followers).not_to include(@joel)
      end
    end

    context 'auto-follow' do
      it 'includes users who have both global and messageboard auto-follow enabled' do
        @sara = create(:user, name: 'sara', email: 'sara@example.com')
        create(:user_preference, user: @sara, auto_follow_topics: true)
        create(:user_messageboard_preference, user: @sara, auto_follow_topics: true, messageboard: @messageboard)
        expect(AutofollowUsers.new(@post).new_followers).to include(@sara => :auto)
      end

      it 'includes users who have global auto-follow disabled and messageboard auto-follow enabled' do
        @sara = create(:user, name: 'sara', email: 'sara@example.com')
        create(:user_preference, user: @sara, auto_follow_topics: false)
        create(:user_messageboard_preference, user: @sara, auto_follow_topics: true, messageboard: @messageboard)
        expect(AutofollowUsers.new(@post).new_followers).to include(@sara => :auto)
      end

      it 'does not include users who have global auto-follow enabled but messageboard auto-follow disabled' do
        @sara = create(:user, name: 'sara', email: 'sara@example.com')
        create(:user_preference, user: @sara, auto_follow_topics: true)
        create(:user_messageboard_preference, user: @sara, auto_follow_topics: false, messageboard: @messageboard)
        expect(AutofollowUsers.new(@post).new_followers).not_to include(@sara)
      end

      it 'does not include users who have both global and messageboard auto-follow disabled' do
        @sara = create(:user, name: 'sara', email: 'sara@example.com')
        create(:user_preference, user: @sara, auto_follow_topics: false)
        create(:user_messageboard_preference, user: @sara, auto_follow_topics: false, messageboard: @messageboard)
        expect(AutofollowUsers.new(@post).new_followers).not_to include(@sara)
      end
    end

    context 'with thredded_user_preferences.auto_follow_topics default true' do
      around(:all) do |ex|
        ActiveRecord::Migration.change_column_default :thredded_user_preferences, :auto_follow_topics, true
        Thredded::UserPreference.reset_column_information
        ex.run
        ActiveRecord::Migration.change_column_default :thredded_user_preferences, :auto_follow_topics, false
        Thredded::UserPreference.reset_column_information
      end

      it 'respects the default column value' do
        sara = create(:user, name: 'sara', email: 'sara@example.com')
        expect(AutofollowUsers.new(@post).new_followers).to include(sara)
      end
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
      topic = create(:topic)
      build(:post, user: user, content: 'hi @john', messageboard: messageboard, postable: topic)
    end
  end
end
