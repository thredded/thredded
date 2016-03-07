require 'spec_helper'

module Thredded
  describe MessageboardDestroyer, '#.run' do
    it 'destroys messageboard and all associated data' do
      messageboard = create(:messageboard, slug: 'goodbye')
      category = create(:category, messageboard: messageboard)
      post = create(:post, messageboard: messageboard)
      topic = create(:topic, messageboard: messageboard)
      notification_preference = create(:notification_preference, messageboard: messageboard)

      Thredded::MessageboardDestroyer.new('goodbye').run

      expect { Thredded::Category.find(category.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Thredded::NotificationPreference.find(notification_preference.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Thredded::Post.find(post.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { Thredded::Topic.find(topic.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
