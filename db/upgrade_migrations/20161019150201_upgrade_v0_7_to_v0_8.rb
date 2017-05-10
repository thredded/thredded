# frozen_string_literal: true

require 'thredded/base_migration'

class UpgradeV07ToV08 < Thredded::BaseMigration
  def up
    closed_messageboards = Thredded::Messageboard.unscoped.where(closed: true).to_a
    if closed_messageboards.present?
      fail ActiveRecord::MigrationError, <<-TEXT
There are #{closed_messageboards.length} closed Messageboards:
#{closed_messageboards.map { |m| "#{m.name} (id=#{m.id})" }.join("\n")}
Support for closed messageboards has been removed in thredded v0.8.0.
Delete or un-close these messageboards and consider using the "paranoia" gem to support soft deletion instead.
      TEXT
    end
    remove_index :thredded_messageboards, name: :index_thredded_messageboards_on_closed
    remove_column :thredded_messageboards, :closed
    add_column :thredded_user_preferences, :followed_topic_emails, :boolean, default: true, null: false
    add_column :thredded_user_messageboard_preferences, :followed_topic_emails, :boolean, default: true, null: false
    rename_column :thredded_user_preferences, :notify_on_mention, :follow_topics_on_mention
    rename_column :thredded_user_messageboard_preferences, :notify_on_mention, :follow_topics_on_mention
    change_column :thredded_messageboards, :name, :string, limit: 191
  end

  def down
    change_column :thredded_messageboards, :name, :string, limit: 255
    rename_column :thredded_user_messageboard_preferences, :follow_topics_on_mention, :notify_on_mention
    rename_column :thredded_user_preferences, :follow_topics_on_mention, :notify_on_mention
    remove_column :thredded_user_messageboard_preferences, :followed_topic_emails
    remove_column :thredded_user_preferences, :followed_topic_emails
    add_column :thredded_messageboards, :closed, :boolean, default: false, null: false
    add_index :thredded_messageboards, :closed, name: :index_thredded_messageboards_on_closed
  end
end
