# frozen_string_literal: true

require 'thredded/base_migration'

class UpgradeThreddedV015ToV016 < Thredded::BaseMigration
  def up
    %i[thredded_user_topic_read_states thredded_user_private_topic_read_states].each do |table_name|
      add_column table_name, :unread_posts_count, :integer, default: 0, null: false
      add_column table_name, :read_posts_count, :integer, default: 0, null: false
    end
    add_column :thredded_user_topic_read_states, :messageboard_id, column_type(:thredded_messageboards, :id)
    set_messageboard_ids
    change_column_null :thredded_user_topic_read_states, :messageboard_id, false
    add_index :thredded_user_topic_read_states, :messageboard_id
    add_index :thredded_user_topic_read_states, %i[user_id messageboard_id],
              name: :thredded_user_topic_read_states_user_messageboard
    [Thredded::UserTopicReadState, Thredded::UserPrivateTopicReadState].each do |klass|
      klass.reset_column_information
      klass.update_post_counts!
    end
  end

  def down
    remove_column :thredded_user_topic_read_states, :messageboard_id
    %i[thredded_user_topic_read_states thredded_user_private_topic_read_states].each do |table|
      remove_column table, :unread_posts_count
    end
  end

  private

  def set_messageboard_ids
    messageboard_topics = Thredded::Topic.pluck(:messageboard_id, :id).group_by(&:first)
    messageboard_topics.transform_values! { |v| v.map(&:second) }
    messageboard_topics.each do |messageboard_id, topic_ids|
      say "Setting messageboard_id #{messageboard_id} for postable_id IN (#{topic_ids.join(',')})"
      Thredded::UserTopicReadState.where(postable_id: topic_ids).update_all(messageboard_id: messageboard_id)
    end
  end
end
