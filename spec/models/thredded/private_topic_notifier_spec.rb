require 'spec_helper'

describe PrivateTopicNotifier, '#private_topic_recipients' do
  before do
    @john = build_stubbed(:user)
    @joel = build_stubbed(:user)
    @sam  = build_stubbed(:user)
  end

  it 'returns everyone but the sender' do
    post = build_stubbed(:post, post_notifications: [])
    private_topic = build_stubbed(:private_topic, user: @john,
      users: [@john, @joel, @sam], posts: [post])

    recipients = PrivateTopicNotifier.new(private_topic).private_topic_recipients
    recipients.should eq [@joel, @sam]
  end

  it 'excludes anyone whose preferences say not to notify' do
    post = build_stubbed(:post, post_notifications: [])
    private_topic = build_stubbed(:private_topic, user: @john,
      users: [@john, @joel, @sam], posts: [post])
    @joel.stubs(private_message_notifications_for?: false)

    recipients = PrivateTopicNotifier.new(private_topic).private_topic_recipients
    recipients.should eq [@sam]
  end

  it 'excludes anyone who has already been notified' do
    prev_notification = build_stubbed(:post_notification, email: @joel.email)
    post = build_stubbed(:post, post_notifications: [prev_notification])
    private_topic = build_stubbed(:private_topic, user: @john, posts: [post],
      users: [@john, @joel, @sam])

    recipients = PrivateTopicNotifier.new(private_topic).private_topic_recipients
    recipients.should eq [@sam]
  end

  it 'marks the right users as modified' do
    joel = create(:user, email: 'joel@example.com')
    sam = create(:user, email: 'sam@example.com')
    john = create(:user)
    site = create(:site)
    messageboard = create(:messageboard, site: site)
    private_topic = create(:private_topic, user: john,
      users: [john, joel, sam], messageboard: messageboard)
    create(:post, content: 'hi', topic: private_topic)

    PrivateTopicNotifier.new(private_topic).notifications_for_private_topic

    private_topic.posts.first.post_notifications.map(&:email)
      .should eq(['sam@example.com', 'joel@example.com'])
  end
end
