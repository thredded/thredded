# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe 'Notifications preferences', thredded_reset: [:@notifiers] do
    let(:user_preferences) { create(:user_preferences) }
    let(:notifier) { MockNotifier.new }
    before do
      Thredded.notifiers = [Thredded::EmailNotifier.new, notifier]
    end
    RSpec.shared_examples 'notifier access' do
      it 'can find its own notifier' do
        expect(subject.notifier).to eq(notifier)
      end
      it "can find its own notifier's human name" do
        expect(subject.notifier_human_name).to eq(notifier.human_name)
      end
    end

    describe MessageboardNotificationsForFollowedTopics do
      subject { create(:messageboard_notifications_for_followed_topics, notifier_key: notifier.key) }
      include_examples 'notifier access'
    end
    describe NotificationsForFollowedTopics do
      subject { create(:notifications_for_followed_topics, notifier_key: notifier.key) }
      include_examples 'notifier access'
    end
    describe NotificationsForPrivateTopics do
      subject { create(:notifications_for_private_topics, notifier_key: notifier.key) }
      include_examples 'notifier access'
    end
  end
end
