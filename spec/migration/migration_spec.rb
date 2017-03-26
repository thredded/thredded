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

  # create a record bypassing ActiveRecord
  # @return [Integer] record id
  def insert_record(klass, attributes)
    klass.unscoped.insert(
      attributes.reverse_merge(created_at: Time.zone.now, updated_at: Time.zone.now)
        .each_with_object({}) { |(k, v), h| h[klass.arel_table[k]] = v }
    )
  end

  context 'v0.8 to v0.9' do
    let(:migration_file) { 'db/upgrade_migrations/20161113161801_upgrade_v0_8_to_v0_9.rb' }

    it 'has got some users (check the sample data)' do
      expect(User.count).to be > 2
    end

    it 'migrates notifications_for_private_topics' do
      one_f_id = create(:user_preference, notify_on_message: false, followed_topic_emails: false).id
      two_t_id = create(:user_preference, notify_on_message: true, followed_topic_emails: true).id
      mone_f_id = insert_record Thredded::UserMessageboardPreference,
                                followed_topic_emails: false,
                                user_id: create(:user).id,
                                messageboard_id: create(:messageboard).id
      mtwo_t_id = insert_record Thredded::UserMessageboardPreference,
                                followed_topic_emails: true,
                                user_id: create(:user).id,
                                messageboard_id: create(:messageboard).id
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

      messageboard_id, user_id = Thredded::UserMessageboardPreference.where(id: mone_f_id)
        .pluck(:messageboard_id, :user_id)[0]
      expect(Thredded::MessageboardNotificationsForFollowedTopics
               .where(messageboard_id: messageboard_id, user_id: user_id)
               .map { |n| [n.notifier_key, n.enabled?] })
        .to eq([['email', false]])
      messageboard_id, user_id = Thredded::UserMessageboardPreference.where(id: mtwo_t_id)
        .pluck(:messageboard_id, :user_id)[0]
      expect(Thredded::MessageboardNotificationsForFollowedTopics
               .where(messageboard_id: messageboard_id, user_id: user_id)
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
