# frozen_string_literal: true
require 'spec_helper'
Rails.env = 'test'
MIGRATION_FILE = 'db/upgrade_migrations/20161113161801_upgrade_v0_8_to_v0_9.rb'
MIGRATION = MIGRATION_FILE.split('/').last.split('_').first
# load MIGRATION_FILE

describe '0.9 migration', migration_spec: true do
  # subject { ActiveRecord::Migrator.migrate MIGRATION_FILE.split('/').last.split('_').first}
  subject do
    begin
      verbose_was = ActiveRecord::Migration.verbose
      ActiveRecord::Migration.verbose = false
      Thredded::DbTools.silence_active_record do
        ActiveRecord::Migrator.migrate('db/upgrade_migrations') do |m|
          m.filename.include?('upgrade_v0_8_to_v0_9')
        end
      end
    ensure
      ActiveRecord::Migration.verbose = verbose_was
    end
  end

  it 'has got some users (check the sample data)' do
    expect(User.count).to be > 2
  end

  it 'migrates notifications_for_private_topics' do
    one_f_id = create(:user_preference, notify_on_message: false, followed_topic_emails: false).id
    two_t_id = create(:user_preference, notify_on_message: true, followed_topic_emails: true).id
    mone_f_id = create(:user_messageboard_preference, followed_topic_emails: false).id
    mtwo_t_id = create(:user_messageboard_preference, followed_topic_emails: true).id
    subject

    expect(Thredded::UserPreference.find(one_f_id)
      .notifications_for_private_topics.map { |n| [n.notifier_key, n.enabled?] })
      .to eq([['email', false]])
    expect(Thredded::UserPreference.find(two_t_id)
      .notifications_for_private_topics.map { |n| [n.notifier_key, n.enabled?] })
      .to eq([['email', true]])

    expect(Thredded::UserPreference.find(one_f_id)
      .notifications_for_followed_topics.map { |n| [n.notifier_key, n.enabled?] })
      .to eq([['email', false]])
    expect(Thredded::UserPreference.find(two_t_id)
      .notifications_for_followed_topics.map { |n| [n.notifier_key, n.enabled?] })
      .to eq([['email', true]])

    ump = Thredded::UserMessageboardPreference.find(mone_f_id)
    expect(Thredded::MessageboardNotificationsForFollowedTopics
      .where(messageboard_id: ump.messageboard_id, user_id: ump.user_id)
      .map { |n| [n.notifier_key, n.enabled?] })
      .to eq([['email', false]])
    ump = Thredded::UserMessageboardPreference.find(mtwo_t_id)
    expect(Thredded::MessageboardNotificationsForFollowedTopics
      .where(messageboard_id: ump.messageboard_id, user_id: ump.user_id)
      .map { |n| [n.notifier_key, n.enabled?] })
      .to eq([['email', true]])
  end

  it 'smoke test' do
    subject
  end
end
