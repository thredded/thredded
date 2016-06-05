# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe NotifyPrivateTopicUsers do
    before do
      @john = create(:user)
      @joel = create(:user, email: 'joel@example.com')
      @sam  = create(:user, email: 'sam@example.com')
    end
    let(:private_topic) { create(:private_topic, user: @john, users: [@john, @joel, @sam]) }

    describe '#private_topic_recipients' do
      it 'returns everyone but the sender' do
        post = build_stubbed(:private_post, postable: private_topic, post_notifications: [], user: @john)
        recipients = NotifyPrivateTopicUsers.new(post).private_topic_recipients
        expect(recipients).not_to include @john
      end

      it 'excludes anyone whose preferences say not to notify' do
        post = build_stubbed(:private_post, postable: private_topic, post_notifications: [], user: @john)
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

        recipients = NotifyPrivateTopicUsers.new(post).private_topic_recipients
        expect(recipients).to include(@sam)
        expect(recipients).not_to include(@joel)
      end

      it 'excludes anyone who has already been notified' do
        post = build_stubbed(:private_post, postable: private_topic, user: @john)
        create(:post_notification, email: @joel.email, post: post)

        recipients = NotifyPrivateTopicUsers.new(post).private_topic_recipients
        expect(recipients).not_to include(@joel)
        expect(recipients).to include(@sam)
      end
    end

    describe '#run' do
      it 'marks the right users as modified' do
        private_post = create(:private_post, content: 'hi', postable: private_topic, user: @john)

        NotifyPrivateTopicUsers.new(private_post).run

        emails = private_topic.posts.first.post_notifications.map(&:email)
        expect(emails).to include('joel@example.com')
        expect(emails).to include('sam@example.com')
        expect(emails.size).to eq(2)
      end
    end
  end
end
