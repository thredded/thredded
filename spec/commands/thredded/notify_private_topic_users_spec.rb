# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe NotifyPrivateTopicUsers, '#run' do
    before do
      @john = create(:user)
      @joel = create(:user)
      @sam  = create(:user)
    end

    it 'returns everyone but the sender' do
      post = create(:private_post, post_notifications: [])
      private_topic = create(
        :private_topic,
        user: @john,
        users: [@john, @joel, @sam],
        posts: [post],
      )
      recipients = NotifyPrivateTopicUsers.new(private_topic).private_topic_recipients
      expect(recipients).not_to include @john
    end

    it 'excludes anyone whose preferences say not to notify' do
      post = create(:private_post, post_notifications: [])
      private_topic = create(
        :private_topic,
        user: @john,
        users: [@john, @joel, @sam],
        posts: [post]
      )
      create(
        :user_preference,
        user: @joel,
        notify_on_message: false
      )
      create(
        :user_preference,
        user: @sam,
        notify_on_message: true
      )

      recipients = NotifyPrivateTopicUsers.new(private_topic).private_topic_recipients
      expect(recipients).to eq [@sam]
    end

    it 'excludes anyone who has already been notified' do
      private_topic = create(
        :private_topic,
        user: @john,
        users: [@john, @joel, @sam])
      post = create(:private_post, postable: private_topic)
      create(:post_notification, email: @joel.email, post: post)

      recipients = NotifyPrivateTopicUsers.new(private_topic).private_topic_recipients
      expect(recipients).to eq [@sam]
    end

    it 'marks the right users as modified' do
      joel = create(:user, email: 'joel@example.com')
      sam = create(:user, email: 'sam@example.com')
      john = create(:user)
      private_topic = create(
        :private_topic,
        user: john,
        users: [john, joel, sam]
      )
      create(:private_post, content: 'hi', postable: private_topic)

      NotifyPrivateTopicUsers.new(private_topic).run

      emails = private_topic.posts.first.post_notifications.map(&:email)
      expect(emails).to include('joel@example.com')
      expect(emails).to include('sam@example.com')
      expect(emails.size).to eq(2)
    end
  end
end
