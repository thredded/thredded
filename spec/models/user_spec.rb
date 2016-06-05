# frozen_string_literal: true
require 'spec_helper'

describe User, '.to_s' do
  it 'returns the username string' do
    user = create(:user, name: 'Joseph')

    expect(user.to_s).to eq 'Joseph'
  end
end

describe User, '.following?(topic)' do
  it 'returns the follow if user is following the topic' do
    user = create(:user, name: 'Joseph')
    topic = create(:topic)
    follow = create(:user_topic_follow, user: user, topic: topic)
    expect(user.following?(topic)).to be_truthy
    expect(user.following?(topic)).to eq(follow)
  end

  it 'returns false if user is not following the topic' do
    user = create(:user, name: 'Joseph')
    topic = create(:topic)
    expect(user.following?(topic)).to be_falsey
  end
end
