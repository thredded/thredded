require 'spec_helper'

module Thredded
  describe NotifyMentionedUsers, '#run' do
    before do
      @sam  = create(:user, name: 'sam')
      @joel = create(:user, name: 'joel', email: 'joel@example.com')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @post = build(:post, user: @sam, content: 'hey @joel and @john. - @sam')
      @messageboard = @post.messageboard
    end

    it 'respects global notification preferences' do
      create(
        :user_preference,
        user: @joel,
        notify_on_mention: true,
      )
      create(
        :user_messageboard_preference,
        user: @joel,
        notify_on_mention: false,
        messageboard: @messageboard,
      )
      create(
        :user_preference,
        user: @john,
        notify_on_mention: false,
      )
      create(
        :user_messageboard_preference,
        user: @john,
        notify_on_mention: true,
        messageboard: @messageboard,
      )

      expect(NotifyMentionedUsers.new(@post).at_notifiable_members).to be_empty
    end

    it 'returns 2 users mentioned, not including post author' do
      create(
        :user_messageboard_preference,
        user: @joel,
        notify_on_mention: true,
        messageboard: @messageboard,
      )
      create(
        :user_messageboard_preference,
        user: @john,
        notify_on_mention: true,
        messageboard: @messageboard,
      )

      notifier = NotifyMentionedUsers.new(@post)
      at_notifiable_members = notifier.at_notifiable_members
      expect(at_notifiable_members).to match_array([@joel, @john])
    end

    it 'does not return any users already emailed about this post' do
      create(
        :user_messageboard_preference,
        user: @john,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      create(
        :user_messageboard_preference,
        user: @joel,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      @post.save!
      PostNotification.where.not(email: @joel.email).delete_all
      notifier = NotifyMentionedUsers.new(@post)

      expect(notifier.at_notifiable_members).to eq([@john])
    end

    it 'does not return users not included in a private topic' do
      private_post = build(:private_post, user: @sam, content: 'hey @joel and @john. - @sam')
      create(
        :user_messageboard_preference,
        user: @joel,
        notify_on_mention: true,
      )
      private_post.postable = create(
        :private_topic,
        user: private_post.user,
        last_user: private_post.user,
        users: [@joel]
      )
      notifier = NotifyMentionedUsers.new(private_post)

      expect(notifier.at_notifiable_members).to eq([@joel])
    end

    it 'does not return users that set their preference to "no @ notifications"' do
      create(
        :user_messageboard_preference,
        user: @john,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      create(
        :user_messageboard_preference,
        notify_on_mention: false,
        user: @joel,
        messageboard: @post.messageboard,
      )
      notifier = NotifyMentionedUsers.new(@post)
      at_notifiable_members = notifier.at_notifiable_members

      expect(at_notifiable_members).to eq([@john])
    end
  end

  describe NotifyMentionedUsers, '#notifications_for_at_users' do
    before do
      sam  = create(:user, name: 'sam')
      @joel = create(:user, name: 'joel', email: 'joel@example.com')
      @john = create(:user, name: 'john', email: 'john@example.com')
      @post = create_post_by(sam)

      @messageboard = @post.messageboard
    end

    it 'does not notify any users already emailed about this post' do
      create(
        :user_messageboard_preference,
        user: @john,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      create(
        :user_messageboard_preference,
        user: @joel,
        messageboard: @messageboard,
        notify_on_mention: true,
      )
      NotifyMentionedUsers.new(@post).run
      notified_emails = @post.post_notifications.map(&:email)

      expect(notified_emails).to match_array(%w(joel@example.com john@example.com))
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
