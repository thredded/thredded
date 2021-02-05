# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe PrivateTopicsController, type: :controller do
    routes { Thredded::Engine.routes }

    subject(:do_mark_all_as_read) { post :mark_all_as_read }

    let(:user) { create(:user) }

    before do
      allow(controller).to receive_messages(thredded_current_user: user)
      request.env['HTTP_REFERER'] = root_path
    end

    shared_examples 'private topic creation' do
      it 'creates one' do
        expect { do_create }.to change(PrivateTopic, :count)
      end

      it 'calls the notification command on create' do
        notifier = instance_double(NotifyPrivateTopicUsers)
        expect(NotifyPrivateTopicUsers).to receive(:new).with(an_instance_of(PrivatePost)).and_return(notifier)
        expect(notifier).to receive(:run)
        do_create
      end
    end

    describe 'create with user IDs' do
      subject(:do_create) do
        post :create, params: {
          private_topic: { content: 'blah', user_ids: [create(:user).id], title: 'titleasdfa' }
        }
      end

      include_examples 'private topic creation'
    end

    describe 'create with user names' do
      subject(:do_create) do
        post :create, params: {
          private_topic: { content: 'blah', user_names: create(:user).name, title: 'titleasdfa' }
        }
      end

      include_examples 'private topic creation'
    end

    describe 'mark all as read' do
      before do
        allow(controller).to receive(:thredded_signed_in?).and_return(true)
      end

      it 'calls MarkAllRead service' do
        expect(MarkAllRead).to receive(:run).with(user)

        do_mark_all_as_read
      end
    end
  end
end
