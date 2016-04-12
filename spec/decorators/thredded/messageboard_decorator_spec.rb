require 'spec_helper'

module Thredded
  describe MessageboardDecorator, '#meta' do
    it 'outputs a humanized count of topics and posts' do
      messageboard = create(
        :messageboard,
        topics_count: 40_343,
        posts_count: 134_500
      )
      decorated_messageboard = MessageboardDecorator.new(messageboard)
      expected_result = '40.3 thousand topics / 135 thousand posts'

      expect(decorated_messageboard.meta).to eq expected_result
    end
  end

  describe MessageboardDecorator, '#latest_topic' do
    it 'returns the most recently updated topic' do
      messageboard = create(:messageboard)
      create_list(:topic, 2, messageboard: messageboard)
      latest = create(:topic, messageboard: messageboard)
      decorated_messageboard = MessageboardDecorator.new(messageboard)

      expect(decorated_messageboard.latest_topic).to eq latest
    end
  end

  describe MessageboardDecorator, '#latest_user' do
    it 'returns the user from the most recently updated topic' do
      me = create(:user)
      them = create(:user)
      messageboard = create(:messageboard)
      create_list(:topic, 2, messageboard: messageboard)
      create(:topic, messageboard: messageboard, last_user: them, user: me)
      decorated_messageboard = MessageboardDecorator.new(messageboard)

      expect(decorated_messageboard.latest_user).to eq them
    end
  end
end
