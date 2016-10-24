# frozen_string_literal: true
class TestNotifier
  mattr_accessor :users_notified_of_new_post, :users_notified_of_new_private_post

  def new_post(_post, users)
    self.users_notified_of_new_post = users
  end

  def new_private_post(_post, users)
    self.users_notified_of_new_private_post = users
  end

  def self.resetted
    users_notified_of_new_post = nil
    users_notified_of_new_private_post = nil
  end
end
