# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe MarkAllRead, '#run' do
    subject { MarkAllRead.run(user_to_mark) }

    context 'there are unread topics' do
      let(:private_topic) { create(:private_topic) }
      let(:user_read_all) { private_topic.user }
      let(:user_to_mark) { private_topic.users.first }
      let!(:posts) { create_list(:private_post, 5, postable: private_topic, user: user_read_all) }

      it 'marks them as read' do
        expect { subject }.to change { UserPrivateTopicReadState.where(user: user_to_mark).count }.by(1)
      end
    end

    context 'there are no topics' do
      let(:user_to_mark) { create(:user) }

      it 'makes no changes' do
        expect { subject }.not_to change { UserPrivateTopicReadState.where(user: user_to_mark).count }
      end
    end

    context 'there are no unread topics' do
      let(:user_private_topic_read_state) { create(:user_private_topic_read_state) }
      let(:user_to_mark) { user_private_topic_read_state.user }

      it 'makes no changes' do
        expect { subject }.not_to change { UserPrivateTopicReadState.where(user: user_to_mark).count }
      end
    end
  end
end
