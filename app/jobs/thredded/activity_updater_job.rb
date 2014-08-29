module Thredded
  class ActivityUpdaterJob
    include Q::Methods

    queue(:update_user_activity) do |options|
      role = Role.find_by(
        messageboard_id: options['messageboard_id'],
        user_id: options['user_id']
      )
      role.update_attribute(:last_seen, Time.now.utc) if role
    end
  end
end
