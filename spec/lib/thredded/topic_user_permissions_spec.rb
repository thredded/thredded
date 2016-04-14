# frozen_string_literal: true
require 'spec_helper'
require 'thredded/topic_user_permissions'

module Thredded
  describe TopicUserPermissions do
    describe '#creatable?' do
      let(:topic) { create(:topic) }
      let(:user_details) { Thredded::UserDetail.new }

      it 'allows members to create a topic' do
        user = create(:user)
        permissions = Thredded::TopicUserPermissions.new(topic, user)

        expect(permissions).to be_creatable
      end

      it 'does not allow non-members to create a topic' do
        messageboard = create(:messageboard)
        topic = create(:topic, messageboard: messageboard)
        user = create(:user)
        allow(user).to receive(:thredded_can_write_messageboards) { Messageboard.none }
        permissions = TopicUserPermissions.new(topic, user)

        expect(permissions).not_to be_creatable
      end
    end
  end
end
