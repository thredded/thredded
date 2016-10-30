# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe 'User and UserMessageboard Preferences' do
    shared_examples_for 'notifications_for_followed_topics' do
      it 'defaults to true for any notifier' do
        expect(subject.notifications_for_followed_topics[email_notifier.key]).to be_truthy
        expect(subject.notifications_for_followed_topics[mock_notifier.key]).to be_truthy
        subject.save
        subject.reload
        expect(subject.notifications_for_followed_topics[email_notifier.key]).to be_truthy
        expect(subject.notifications_for_followed_topics[mock_notifier.key]).to be_truthy
      end
      it 'can be turned off (persistable)' do
        subject.notifications_for_followed_topics[email_notifier.key] = false
        expect(subject.notifications_for_followed_topics[email_notifier.key]).to be_falsey
        expect(subject.notifications_for_followed_topics[mock_notifier.key]).to be_truthy
        subject.save
        subject.reload
        expect(subject.notifications_for_followed_topics[email_notifier.key]).to be_falsey
        expect(subject.notifications_for_followed_topics[mock_notifier.key]).to be_truthy
      end
    end
    shared_examples_for 'notifications_for_private_topics' do
      it 'defaults to true for any notifier' do
        expect(subject.notifications_for_private_topics[email_notifier.key]).to be_truthy
        expect(subject.notifications_for_private_topics[mock_notifier.key]).to be_truthy
        subject.save
        subject.reload
        expect(subject.notifications_for_private_topics[email_notifier.key]).to be_truthy
        expect(subject.notifications_for_private_topics[mock_notifier.key]).to be_truthy
      end
      it 'can be turned off (persistable)' do
        subject.notifications_for_private_topics[email_notifier.key] = false
        expect(subject.notifications_for_private_topics[email_notifier.key]).to be_falsey
        expect(subject.notifications_for_private_topics[mock_notifier.key]).to be_truthy
        subject.save
        subject.reload
        expect(subject.notifications_for_private_topics[email_notifier.key]).to be_falsey
        expect(subject.notifications_for_private_topics[mock_notifier.key]).to be_truthy
      end
    end

    let(:user) { create :user }
    let(:email_notifier) { EmailNotifier.new }
    let(:mock_notifier) { MockNotifier.new }

    describe 'UserPreference' do
      subject { user.thredded_user_preference }
      it_behaves_like 'notifications_for_followed_topics'
      it_behaves_like 'notifications_for_private_topics'
    end

    describe UserMessageboardPreference do
      let(:messageboard) { create :messageboard }
      subject { user.thredded_user_messageboard_preferences.in(messageboard) }
      it_behaves_like 'notifications_for_followed_topics'
    end
  end
end
