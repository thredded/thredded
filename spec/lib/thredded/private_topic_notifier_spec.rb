require 'spec_helper'
require 'thredded/private_topic_notifier'

module Thredded
  describe PrivateTopicNotifier, '#private_topic_recipients' do
    before do
      @john = create(:user)
      @joel = create(:user)
      @sam  = create(:user)
    end

    it 'returns everyone but the sender' do
      post = create(:post, post_notifications: [])
      private_topic = create(:private_topic,
        user: @john,
        users: [@john, @joel, @sam],
        posts: [post],
      )
      create(:messageboard_preference,
        user: @john,
        messageboard: private_topic.messageboard,
      )
      create(:messageboard_preference,
        user: @joel,
        messageboard: private_topic.messageboard,
      )
      create(:messageboard_preference,
         user: @sam,
         messageboard: private_topic.messageboard,
      )

      recipients = PrivateTopicNotifier.new(private_topic).private_topic_recipients
      recipients.should_not include @john
    end

    it 'excludes anyone whose preferences say not to notify' do
      post = create(:post, post_notifications: [])
      private_topic = create(:private_topic,
        user: @john,
        users: [@john, @joel, @sam],
        posts: [post]
      )
      create(:messageboard_preference,
        user: @joel,
        messageboard: private_topic.messageboard
      )
      create(:messageboard_preference,
        user: @sam,
        messageboard: private_topic.messageboard,
        notify_on_message: true
      )

      recipients = PrivateTopicNotifier.new(private_topic).private_topic_recipients
      recipients.should eq [@sam]
    end

    it 'excludes anyone who has already been notified' do
      private_topic = create(
        :private_topic,
        user: @john,
        users: [@john, @joel, @sam])
      post = create(:post, postable: private_topic)
      create(:post_notification, email: @joel.email, post: post)
      create(:messageboard_preference,
        user: @joel,
        messageboard: private_topic.messageboard,
        notify_on_message: true
      )
      create(:messageboard_preference,
        user: @sam,
        messageboard: private_topic.messageboard,
        notify_on_message: true
      )

      recipients = PrivateTopicNotifier.new(private_topic).private_topic_recipients
      recipients.should eq [@sam]
    end

    it 'marks the right users as modified' do
      joel = create(:user, email: 'joel@example.com')
      sam = create(:user, email: 'sam@example.com')
      john = create(:user)
      messageboard = create(:messageboard)
      private_topic = create(
        :private_topic,
        user: john,
        users: [john, joel, sam],
        messageboard: messageboard
      )
      create(:post, content: 'hi', postable: private_topic)
      create(
        :messageboard_preference,
        user: sam,
        messageboard: messageboard,
        notify_on_message: true
      )
      create(
        :messageboard_preference,
        user: joel,
        messageboard: messageboard,
        notify_on_message: true
      )

      PrivateTopicNotifier.new(private_topic).notifications_for_private_topic

      private_topic.posts.first.post_notifications.map(&:email)
        .should eq(['joel@example.com', 'sam@example.com'])
    end
  end
end
