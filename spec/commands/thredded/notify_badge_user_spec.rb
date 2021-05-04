# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe NotifyBadgeUser do
    describe '#run' do
      let(:badge) { create(:badge) }
      let(:user) { create(:user) }

      let(:command) { NotifyBadgeUser.new(badge, user) }

      it "doesn't send any emails" do
        expect { command.run }.not_to change { ActionMailer::Base.deliveries.count }
      end

      context 'with the MockNotifier', thredded_reset: [:@notifiers] do
        let(:mock_notifier) { MockNotifier.new }

        before { Thredded.notifiers = [mock_notifier] }

        it "doesn't send any emails" do
          expect { command.run }.not_to change { ActionMailer::Base.deliveries.count }
        end

        it "doesn't send any browser notification" do
          expect { command.run }.not_to change { Notification.count }
        end

        it 'notifies exactly once' do
          expect { command.run }.to change(mock_notifier, :user_notified_of_new_badge)
          expect { command.run }.not_to change(mock_notifier, :user_notified_of_new_badge)
        end
      end

      context 'with multiple notifiers', thredded_reset: [:@notifiers] do
        let(:mock_notifier1) { MockNotifier.new }
        let(:mock_notifier2) { MockNotifier.new }

        before { Thredded.notifiers = [mock_notifier1, mock_notifier2] }

        def count_users_for_each_notifier
          [mock_notifier1.user_notified_of_new_badge.length, mock_notifier2.user_notified_of_new_badge.length]
        end
        it 'notifies via all notifiers' do
          expect { command.run }
            .to change { count_users_for_each_notifier }.from([0, 0]).to([1, 1])
        end
        it "second run doesn't notify" do
          command.run
          expect { command.run }
            .not_to change { count_users_for_each_notifier }
        end
      end
    end
  end
end
