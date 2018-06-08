# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe NotifyPrivateTopicUsers do
    before do
      @john = create(:user)
      @joel = create(:user, email: 'joel@example.com')
      @sam = create(:user, email: 'sam@example.com')
    end
    let(:private_topic) { create(:private_topic, user: @john, users: [@john, @joel, @sam]) }
    let(:notifier) { EmailNotifier.new }

    describe '#targeted_users' do
      let(:post) { build_stubbed(:private_post, postable: private_topic, user: @john) }

      it 'returns everyone but the sender' do
        recipients = NotifyPrivateTopicUsers.new(post).targeted_users(notifier)
        expect(recipients).not_to include @john
        expect(recipients).to include(@sam)
      end

      context 'when preferences say not to notify on email' do
        it "doesn't include them" do
          create(
            :user_preference,
            user: @joel,
          )
          create(:notifications_for_private_topics, notifier_key: 'email', user: @joel, enabled: false)
          recipients = NotifyPrivateTopicUsers.new(post).targeted_users(notifier)
          expect(recipients).not_to include(@joel)
        end

        context 'but with MockNotifier' do
          it 'includes them' do
            recipients = NotifyPrivateTopicUsers.new(post).targeted_users(MockNotifier.new)
            expect(recipients).to include(@joel)
          end
        end
      end
    end

    describe '#run' do
      let(:private_post) { create(:private_post, content: 'hi', postable: private_topic, user: @john) }

      let(:command) { NotifyPrivateTopicUsers.new(private_post) }
      let(:targeted_users) { [build_stubbed(:user)] }
      before { allow(command).to receive(:targeted_users).and_return(targeted_users) }

      it 'sends some emails' do
        expect { command.run }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      context 'with the MockNotifier', thredded_reset: [:@notifiers] do
        let(:mock_notifier) { MockNotifier.new }

        before { Thredded.notifiers = [mock_notifier] }
        it "doesn't send any emails" do
          expect { command.run }.not_to change { ActionMailer::Base.deliveries.count }
        end
        it 'uses MockNotifier' do
          expect { command.run }.to change { mock_notifier.users_notified_of_new_private_post }
        end
      end

      context 'with multiple notifiers', thredded_reset: [:@notifiers] do
        let(:mock_notifier1) { MockNotifier.new }
        let(:mock_notifier2) { MockNotifier.new }

        before { Thredded.notifiers = [mock_notifier1, mock_notifier2] }

        def count_users_for_each_notifier
          [
            mock_notifier1.users_notified_of_new_private_post.length,
            mock_notifier2.users_notified_of_new_private_post.length
          ]
        end
        it 'notifies via all notifiers' do
          expect { command.run }
            .to change { count_users_for_each_notifier }.from([0, 0]).to([1, 1])
        end
        it "second run doesn't notify" do
          command.run
          expect { command.run }
            .to_not change { count_users_for_each_notifier }
        end
      end
    end
  end
end
