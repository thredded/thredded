class PostObserver < ActiveRecord::Observer
  def after_save(post)
    AtNotifier.new(post).notifications_for_at_users
  end
end
