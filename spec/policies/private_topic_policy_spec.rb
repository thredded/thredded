# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe PrivateTopicPolicy do
    subject { described_class }
    permissions :read? do
      it 'granted only to the users in the conversation' do
        alice = build_stubbed(:user)
        bob = build_stubbed(:user)
        eve = build_stubbed(:user)
        private_topic = build_stubbed(:private_topic, user: alice, users: [alice, bob])

        expect(subject).to permit(alice, private_topic)
        expect(subject).to permit(bob, private_topic)
        expect(subject).not_to permit(eve, private_topic)
      end
    end

    permissions :create? do
      it 'granted for non-anonymous users' do
        expect(subject).to permit(Thredded.user_class.new, PrivateTopic.new)
      end
      it 'denied for anonymous users' do
        expect(subject).not_to permit(Thredded::NullUser.new, PrivateTopic.new)
      end
    end
  end
end
