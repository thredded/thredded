# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe NotifyPrivateTopicUsers do
    before do
      @john = create(:user)
      @joel = create(:user, email: 'joel@example.com')
      @sam  = create(:user, email: 'sam@example.com')
    end
    let(:private_topic) { create(:private_topic, user: @john, users: [@john, @joel, @sam]) }

    describe '#private_topic_recipients' do
      it 'returns everyone but the sender' do
        post = build_stubbed(:private_post, postable: private_topic, post_notifications: [], user: @john)
        recipients = NotifyPrivateTopicUsers.new(post).private_topic_recipients
        expect(recipients).not_to include @john
      end
    end

    describe '#run' do
      let(:private_post) { create(:private_post, content: 'hi', postable: private_topic, user: @john) }

      let(:command) { NotifyPrivateTopicUsers.new(private_post) }
      let(:private_topic_recipients) { [build_stubbed(:user)] }
      before { allow(command).to receive(:private_topic_recipients).and_return(private_topic_recipients) }

      it 'marks the right users as modified' do
        emails = private_topic.posts.first.post_notifications.map(&:email)
        expect(emails).to include('joel@example.com')
        expect(emails).to include('sam@example.com')
        expect(emails.size).to eq(2)
      end

      it 'sends some emails' do
        expect { command.run }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      context 'with the test notifier', thredded_reset: ['@@notifiers'] do
        before { Thredded.notifiers = [TestNotifier] }
        it "doesn't send any emails" do
          expect { command.run }.not_to change { ActionMailer::Base.deliveries.count }
        end
        it "doesn't record email notifications" do
          expect { command.run }.not_to change { PostNotification.count }
        end
        it 'uses test notifier' do
          expect { command.run }.to change { TestNotifier.users_notified_of_new_private_post }
        end
      end
    end
  end
end
