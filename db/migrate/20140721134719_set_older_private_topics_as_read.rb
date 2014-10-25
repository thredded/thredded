class SetOlderPrivateTopicsAsRead < ActiveRecord::Migration
  def up
    Thredded::PrivateUser.where('updated_at < ?', 60.days.ago).update_all(read: true)
  end

  def down
    Thredded::PrivateUser.update_all(read: false)
  end
end
