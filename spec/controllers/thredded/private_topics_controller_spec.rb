# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe PrivateTopicsController, type: :controller do
    routes { Thredded::Engine.routes }

    let(:user) { create(:user) }
    before { allow(controller).to receive_messages(thredded_current_user: user) }

    describe 'create' do
      subject { post :create, private_topic: { content: 'blah', user_ids: [create(:user).id], title: 'titleasdfa' } }
      it 'creates one' do
        expect { subject }.to change { PrivateTopic.count }
      end

      it 'calls the notification command on create' do
        notifier = double('NotifyPrivateTopicUsers')
        expect(NotifyPrivateTopicUsers).to receive(:new).with(an_instance_of(PrivatePost)).and_return(notifier)
        expect(notifier).to receive(:run)
        subject
      end
    end
  end
end
