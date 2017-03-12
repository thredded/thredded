# frozen_string_literal: true
require 'spec_helper'
Rails.env = 'test'
# To run the migration tests, run:
# MIGRATION_SPEC=1 rspec spec/migration/migration_spec.rb
describe 'Migrations', migration_spec: true, order: :defined do
  def migrate(migration_file)
    migration_name = File.basename(migration_file)
    verbose_was = ActiveRecord::Migration.verbose
    ActiveRecord::Migration.verbose = false
    Thredded::DbTools.silence_active_record do
      ActiveRecord::Migrator.migrate('db/upgrade_migrations') do |m|
        m.filename.include?(migration_name)
      end
    end
  ensure
    ActiveRecord::Migration.verbose = verbose_was
  end

  context 'v0.8 to v0.9' do
    let(:migration_file) { 'db/upgrade_migrations/20161113161801_upgrade_v0_8_to_v0_9.rb' }

    it 'has got some users (check the sample data)' do
      expect(User.count).to be > 2
    end

    it 'migrates notifications_for_private_topics' do
      one_f_id = create(:user_preference, notify_on_message: false, followed_topic_emails: false).id
      two_t_id = create(:user_preference, notify_on_message: true, followed_topic_emails: true).id
      mone_f_id = create(:user_messageboard_preference, followed_topic_emails: false).id
      mtwo_t_id = create(:user_messageboard_preference, followed_topic_emails: true).id
      migrate(migration_file)

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
  end

  context 'v0.9 to v0.10' do
    let(:migration_file) { 'db/upgrade_migrations/20170125033319_upgrade_v0_9_to_v0_10.rb' }

    it 'smoke test' do
      migrate(migration_file)
    end
  end

  context 'v0.10 to v0.11' do
    let(:migration_file) { 'db/upgrade_migrations/20170312131417_upgrade_thredded_v0_10_to_v0_11.rb' }

    it 'smoke test' do
      migrate(migration_file)
    end
  end
end
