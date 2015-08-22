require 'spec_helper'
require 'chronic'
require 'timecop'

module Thredded
  describe PostDecorator, '#user_name' do
    it 'delegates to the user object' do
      user = build_stubbed(:user, name: 'joel')
      post = build_stubbed(:post, user: user)
      decorated_post = PostDecorator.new(post)

      expect(decorated_post.user_name).to eq 'joel'
    end

    it 'returns Anonymous when there is no user' do
      post = build_stubbed(:post, user: nil)
      decorated_post = PostDecorator.new(post)

      expect(decorated_post.user_name).to eq 'Anonymous'
    end
  end

  describe PostDecorator, '#avatar_url' do
    it 'strips the protocol from the url' do
      post = build_stubbed(:post)
      allow(post).to receive_messages(avatar_url: 'http://example.com/me.jpg')
      decorated_post = PostDecorator.new(post)

      expect(decorated_post.avatar_url).to eq '//example.com/me.jpg'
    end
  end
end
