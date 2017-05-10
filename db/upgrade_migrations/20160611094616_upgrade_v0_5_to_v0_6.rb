# frozen_string_literal: true

require 'thredded/base_migration'

class UpgradeV05ToV06 < Thredded::BaseMigration
  def up
    add_column :thredded_messageboards, :last_topic_id, column_type(:thredded_topics, :id)
    Thredded::Messageboard.reset_column_information
    Thredded::Messageboard.all.each do |messageboard|
      messageboard.update_column :last_topic_id, messageboard.topics.order(updated_at: :desc, id: :desc).first.try(:id)
    end
    change_column_null :thredded_posts, :postable_id, false
    # Allow null on user_id and last_user_id because users can get deleted.
    change_column_null :thredded_topics, :user_id, true
    change_column_null :thredded_topics, :last_user_id, true
    change_column_null :thredded_private_topics, :user_id, true
    change_column_null :thredded_private_topics, :last_user_id, true
  end

  def down
    change_column_null :thredded_private_topics, :last_user_id, false
    change_column_null :thredded_private_topics, :user_id, false
    change_column_null :thredded_topics, :last_user_id, false
    change_column_null :thredded_topics, :user_id, false
    change_column_null :thredded_posts, :postable_id, true
    remove_column :thredded_messageboards, :last_topic_id
  end
end
