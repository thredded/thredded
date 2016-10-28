# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe UserPreference, 'followed_topic_notifications' do
    let(:user) { create :user }
    let(:messageboard) { create :messageboard }
    subject { user.thredded_user_preference }
    it 'defaults to true for any notifier' do
      pending
      expect(subject.followed_topic_notifications[EmailNotifier.key]).to be_truthy
      expect(subject.followed_topic_notifications[MockNotifier.key]).to be_falsey
      subject.save
      subject.reload
      expect(subject.followed_topic_notifications[EmailNotifier.key]).to be_truthy
      expect(subject.followed_topic_notifications[MockNotifier.key]).to be_falsey
    end
    it 'can be turned off (persistable)' do
      pending
      subject.followed_topic_notifications[EmailNotifier.key] = false
      expect(subject.followed_topic_notifications[EmailNotifier.key]).to be_falsey
      expect(subject.followed_topic_notifications[MockNotifier.key]).to be_truthy
      subject.save
      subject.reload
      expect(subject.followed_topic_notifications[EmailNotifier.key]).to be_falsey
      expect(subject.followed_topic_notifications[MockNotifier.key]).to be_truthy
    end
  end
end
