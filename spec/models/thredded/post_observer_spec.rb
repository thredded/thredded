require 'spec_helper'
require 'thredded/at_notifier'

module Thredded
  describe PostObserver, '#after_save' do
    it 'sends at notifications' do
      post = build_stubbed(:post)
      notifier = AtNotifier.new(post)
      notifier.stub(notifications_for_at_users: true)
      AtNotifier.stub(new: notifier)
      observer = PostObserver.instance

      notifier.should_receive(:notifications_for_at_users)

      observer.after_save(post)
    end
  end
end
