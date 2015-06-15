require 'spec_helper'

module Thredded
  describe NotifyMentionedUsers, '#run' do
    before do
      sam  = create(:user, name: 'sam')
      @joel = create(:user, name: 'joel', email: 'joel@example.com')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @post = create(:post, user: sam, content: 'hey @joel and @john. - @sam')
      @messageboard = @post.messageboard

      @messageboard.add_member(@joel)
      @messageboard.add_member(@john)
      @messageboard.add_member(sam)
    end

    it 'returns 2 users mentioned, not including post author' do
      create(
        :notification_preference,
        user: @joel,
        notify_on_mention: true,
        messageboard: @messageboard,
      )
      create(
        :notification_preference,
        user: @john,
        notify_on_mention: true,
        messageboard: @messageboard,
      )

      notifier = NotifyMentionedUsers.new(@post)
      at_notifiable_members = notifier.at_notifiable_members

      expect(at_notifiable_members.size).to eq(2)
      expect(at_notifiable_members).to include @joel
      expect(at_notifiable_members).to include @john
    end

    it 'does not return any users already emailed about this post' do
      create(
        :notification_preference,
        user: @john,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      create(
        :notification_preference,
        user: @joel,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      create(
        :post_notification,
        post: @post,
        email: 'joel@example.com',
      )
      notifier = NotifyMentionedUsers.new(@post)

      expect(notifier.at_notifiable_members.size).to eq(1)
      expect(notifier.at_notifiable_members).to include @john
    end

    it 'does not return users not included in a private topic' do
      create(
        :notification_preference,
        user: @joel,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      @post.postable = create(
        :private_topic,
        user: @post.user,
        last_user: @post.user,
        messageboard: @post.messageboard,
        users: [@joel]
      )
      notifier = NotifyMentionedUsers.new(@post)

      expect(notifier.at_notifiable_members.size).to eq(1)
      expect(notifier.at_notifiable_members).to include @joel
    end

    it 'does not return users that set their preference to "no @ notifications"' do
      create(
        :notification_preference,
        user: @john,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      create(
        :notification_preference,
        notify_on_mention: false,
        user: @joel,
        messageboard: @post.messageboard,
      )
      notifier = NotifyMentionedUsers.new(@post)
      at_notifiable_members = notifier.at_notifiable_members

      expect(at_notifiable_members.size).to eq(1)
      expect(at_notifiable_members).to include @john
      expect(at_notifiable_members).not_to include @joel
    end
  end

  describe NotifyMentionedUsers, '#notifications_for_at_users' do
    before do
      sam  = create(:user, name: 'sam')
      @joel = create(:user, name: 'joel', email: 'joel@example.com')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @post = create_post_by(sam)

      @messageboard = @post.messageboard
      @messageboard.add_member(@joel)
      @messageboard.add_member(@john)
      @messageboard.add_member(sam)
    end

    it 'does not notify any users already emailed about this post' do
      create(
        :notification_preference,
        user: @john,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      create(
        :notification_preference,
        user: @joel,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      NotifyMentionedUsers.new(@post).run
      notified_emails = @post.post_notifications.map(&:email)

      expect(notified_emails.size).to eq(2)
      expect(notified_emails).to include('joel@example.com')
      expect(notified_emails).to include('john@example.com')
    end

    def create_post_by(user)
      messageboard = create(:messageboard)
      create(
        :post,
        user: user,
        content: 'hi @joel and @john. @sam',
        messageboard: messageboard
      )
    end
  end
end
