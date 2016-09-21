# frozen_string_literal: true
class UpgradeV06ToV07 < ActiveRecord::Migration
  def up
    Thredded::MessageboardGroup.transaction do
      Thredded::MessageboardGroup.where(
        name: Thredded::MessageboardGroup.group(:name).having('count(id) > 1').select(:name)
      ).group_by(&:name).each_value do |messageboard_groups|
        messageboard_groups.from(1).each_with_index do |messageboard_group, i|
          messageboard_group.update!(name: "#{messageboard_group.name}-#{i + 1}")
        end
      end
    end

    add_index :thredded_messageboard_groups,
              :name,
              unique: true,
              name: :index_thredded_messageboard_group_on_name

    add_column :thredded_topics, :last_post_at, :datetime
    add_column :thredded_private_topics, :last_post_at, :datetime
    # update existing values to pretty accurate match
    Thredded::Topic.update_all('last_post_at = updated_at')
    Thredded::PrivateTopic.update_all('last_post_at = updated_at')

    add_column :thredded_messageboards, :position, :integer
    Thredded::Messageboard.reset_column_information
    Thredded::Messageboard.all.each { |m| m.update_column(:position, m.created_at.to_i) }
    change_column :thredded_messageboards, :position, :integer, null: false

    add_column :thredded_messageboard_groups, :position, :integer
    Thredded::MessageboardGroup.reset_column_information
    Thredded::MessageboardGroup.all.each { |mg| mg.update_column(:position, mg.created_at.to_i) }
    change_column :thredded_messageboard_groups, :position, :integer, null: false
  end

  def down
    remove_index :thredded_messageboard_groups, name: :index_thredded_messageboard_group_on_name
    remove_column :thredded_topics, :last_post_at
    remove_column :thredded_private_topics, :last_post_at
    remove_column :thredded_messageboards, :position
    remove_column :thredded_messageboard_groups, :position
  end
end
