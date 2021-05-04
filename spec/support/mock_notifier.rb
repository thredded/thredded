# frozen_string_literal: true

require 'set'

class MockNotifier
  attr_accessor :users_notified_of_new_post, :users_notified_of_new_private_post, :user_notified_of_new_badge

  def initialize(key = 'mock')
    @users_notified_of_new_post = Set.new
    @users_notified_of_new_private_post = Set.new
    @user_notified_of_new_badge = Set.new
    @key = key
  end

  attr_reader :key

  def human_name
    "By #{key}"
  end

  def new_post(_post, users)
    users_notified_of_new_post.merge(users)
  end

  def new_private_post(_post, users)
    users_notified_of_new_private_post.merge(users)
  end

  def new_badge(badge, user)
    user_notified_of_new_badge.merge([user])
  end
end
