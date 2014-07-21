require 'spec_helper'

module Thredded
  describe UserReadsPrivateTopic, '#run' do
    it "sets the private user's status as read" do
      private_user = create(:private_user)
      private_topic = private_user.private_topic
      user = private_user.user

      expect(private_user.read).to eq false

      Thredded::UserReadsPrivateTopic.new(private_topic, user).run

      expect(private_user.reload.read).to eq true
    end
  end
end
