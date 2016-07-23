# frozen_string_literal: true
class UpgradeV062ToV063 < ActiveRecord::Migration[5.0]
  def up
    i = 1
    Thredded::MessageboardGroup.order(created_at: :desc).each do |group|
      Rails.logger.info group.id
      next if group.valid?

      group.name = "#{group.name}-#{i}"
      group.save!
      i += 1
    end

    add_index :thredded_messageboard_groups, :name,
              unique: true,
              name: :index_thredded_messageboard_group_on_name
  end

  def down
    remove_index :thredded_messageboard_groups, name: :index_thredded_messageboard_group_on_name
  end
end
