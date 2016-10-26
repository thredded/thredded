# frozen_string_literal: true
class TestNotifier
  mattr_accessor :users_notified_of_new_post, :users_notified_of_new_private_post

  def self.new_post(_post, users)
    self.users_notified_of_new_post = users
  end

  def self.new_private_post(_post, users)
    self.users_notified_of_new_private_post = users
  end
end
