require 'spec_helper'

module Thredded
  describe MessageboardDestroyer, '#.run' do
    it 'destroys messageboard and all associated data' do
      messageboard = create(:messageboard, slug: 'goodbye')
      category = create(:category, messageboard: messageboard)
      post = create(:post, messageboard: messageboard)
      private_topic = create(:private_topic, messageboard: messageboard)
      role = create(:role, messageboard: messageboard)
      topic = create(:topic, messageboard: messageboard)
      messageboard_preference = create(:messageboard_preference, messageboard: messageboard)

      Thredded::MessageboardDestroyer.new('goodbye').run

      expect{ Thredded::Category.find(category.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ Thredded::MessageboardPreference.find(messageboard_preference.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ Thredded::Post.find(post.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ Thredded::PrivateTopic.find(private_topic.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ Thredded::Role.find(role.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ Thredded::Topic.find(topic.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
