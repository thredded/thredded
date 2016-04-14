# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe MessageboardDestroyer, '#.run' do
    it 'destroys messageboard and all associated data' do
      messageboard = create(:messageboard, slug: 'goodbye')
      category = create(:category, messageboard: messageboard)
      post = create(:post, messageboard: messageboard)
      topic = create(:topic, messageboard: messageboard)
      preference = create(:user_messageboard_preference, messageboard: messageboard)

      Thredded::MessageboardDestroyer.new('goodbye').run

      expect(Thredded::Category.find_by_id(category.id)).to be_nil
      expect(Thredded::UserMessageboardPreference.find_by_id(preference.id)).to be_nil
      expect(Thredded::Post.find_by_id(post.id)).to be_nil
      expect(Thredded::Topic.find_by_id(topic.id)).to be_nil
    end
  end
end
