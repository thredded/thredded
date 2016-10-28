# frozen_string_literal: true
require 'spec_helper'
# rubocop:disable StringLiterals

module Thredded
  describe NotifyFollowingUsers do
    describe '#targeted_users' do
      let(:post) { create(:post, user: poster, postable: topic) }
      let(:poster) { create(:user, name: "poster") }
      let!(:follower) { create(:user_topic_follow, user: create(:user, name: "follower"), topic: topic).user }
      let(:topic) { create(:topic, messageboard: messageboard) }
      let!(:messageboard) { create(:messageboard) }
      let(:notifier) { EmailNotifier.new }
      subject { NotifyFollowingUsers.new(post).targeted_users(notifier) }

      it "includes followers where preference to receive these notifications" do
        create(
          :user_messageboard_preference,
          notifications_for_followed_topics: TruthyHashSerializer.create("email" => true),
          user: follower,
          messageboard: messageboard
        )
        expect(subject).to include(follower)
      end

      it "doesn't include the poster, even if they follow" do
        create(:user_topic_follow, user: poster, topic: topic)
        expect(subject).to_not include(poster)
      end

      context "when a follower's email notification is turned off" do
        before do
          create(
            :user_messageboard_preference,
            notifications_for_followed_topics: TruthyHashSerializer.create("email" => false),
            user: follower,
            messageboard: messageboard
          )
        end

        it "doesn't include that user" do
          expect(subject).not_to include(follower)
        end

        context "with the MockNotifier" do
          let(:notifier) { MockNotifier.new.resetted }
          it "does include that user" do
            expect(subject).to include(follower)
          end
        end
      end

      context "when a follower's 'mock' notification is turned off (per messageboard)" do
        before do
          create(
            :user_messageboard_preference,
            notifications_for_followed_topics: TruthyHashSerializer.create("mock" => false),
            user: follower,
            messageboard: messageboard
          )
        end

        context "with the EmailNotifier" do
          let(:notifier) { EmailNotifier.new }
          it "does includes that user" do
            expect(subject).to include(follower)
          end
        end

        context "with the MockNotifier" do
          let(:notifier) { MockNotifier.new.resetted }
          it "doesn't include that user" do
            expect(subject).not_to include(follower)
          end
        end
      end

      context "when a follower's 'mock' notification is turned off (overall)" do
        before do
          create(
            :user_preference,
            notifications_for_followed_topics: TruthyHashSerializer.create("mock" => false),
            user: follower,
          )
        end

        context "with the EmailNotifier" do
          let(:notifier) { EmailNotifier.new }
          it "does includes that user" do
            expect(subject).to include(follower)
          end
        end

        context "with the MockNotifier" do
          let(:notifier) { MockNotifier.new.resetted }
          it "doesn't include that user" do
            expect(subject).not_to include(follower)
          end
        end
      end
    end

    describe '#run' do
      let(:post) { create(:post) }

      let(:command) { NotifyFollowingUsers.new(post) }
      let(:targeted_users) { [build_stubbed(:user)] }
      before { allow(command).to receive(:targeted_users).and_return(targeted_users) }

      it "sends email" do
        expect { command.run }.to change { ActionMailer::Base.deliveries.count }
        # see EmailNotifier spec for more detailed specs
      end

      context "with the MockNotifier", thredded_reset: ["@@notifiers"] do
        before { Thredded.notifiers = [MockNotifier.new.resetted] }
        it "doesn't send any emails" do
          expect { command.run }.not_to change { ActionMailer::Base.deliveries.count }
        end
        it "uses MockNotifier" do
          expect { command.run }.to change { MockNotifier.users_notified_of_new_post }
        end
      end
    end
  end
end
