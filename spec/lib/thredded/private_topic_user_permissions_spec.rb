require 'spec_helper'
require 'thredded/topic_user_permissions'
require 'thredded/private_topic_user_permissions'

module Thredded
  describe PrivateTopicUserPermissions do
    let(:user_details) { Thredded::UserDetail.new }

    describe '#manageable?' do
      it 'is manageable by the user that created it' do
        user = build_stubbed(:user)
        private_topic = build_stubbed(:private_topic, user: user)
        permissions = PrivateTopicUserPermissions.new(private_topic, user, user_details)

        permissions.should be_manageable
      end
    end

    describe '#readable?' do
      it 'allows only users in the conversation to read' do
        me = build_stubbed(:user)
        him = build_stubbed(:user)
        them = build_stubbed(:user)
        private_topic = build_stubbed(:private_topic, user: me, users: [me, him])

        my_permissions = PrivateTopicUserPermissions.new(private_topic, me, user_details)
        his_permissions = PrivateTopicUserPermissions.new(private_topic, him, user_details)
        their_permissions = PrivateTopicUserPermissions.new(private_topic, them, user_details)

        my_permissions.should be_readable
        his_permissions.should be_readable
        their_permissions.should_not be_readable
      end
    end

    describe '#createable?' do
      it 'delegates to normal Topic permissions' do
        user = build_stubbed(:user)
        private_topic = build_stubbed(:private_topic, user: user)
        Thredded::TopicUserPermissions.any_instance.stub('createable?' => true)
        Thredded::TopicUserPermissions.any_instance.should_receive(:createable?)

        PrivateTopicUserPermissions.new(private_topic, user, user_details).createable?
      end
    end
  end
end

