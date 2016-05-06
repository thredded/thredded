class AddViewsCountToThreddedTopics < ActiveRecord::Migration
  def up
    add_column :thredded_topics, :views_count, :integer, default: 0

    Thredded::Topic.all.each do |topic|
      topic.update_attribute(:views_count, topic.user_read_states.count)
    end
  end

  def down
    remove_column :thredded_topics, :views_count
  end
end
