# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe UserResetsPrivateTopicToUnread, '#run' do
    it "sets other users' private topic status as unread" do
      private_user = create(:private_user, read: true)
      private_topic = private_user.private_topic
      user = private_user.user

      other_1 = create(:private_user, private_topic: private_topic, read: true)
      other_2 = create(:private_user, private_topic: private_topic, read: true)

      Thredded::UserResetsPrivateTopicToUnread.new(private_topic, user).run

      expect(private_user.reload.read).to eq true
      expect(other_1.reload.read).to eq false
      expect(other_2.reload.read).to eq false
    end
  end
end
