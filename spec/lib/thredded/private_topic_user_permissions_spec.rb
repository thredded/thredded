require 'spec_helper'
require 'thredded/topic_user_permissions'
require 'thredded/private_topic_user_permissions'

module Thredded
  describe PrivateTopicUserPermissions do
    describe '#readable?' do
      it 'allows only users in the conversation to read' do
        me = build_stubbed(:user)
        him = build_stubbed(:user)
        them = build_stubbed(:user)
        private_topic = build_stubbed(:private_topic, user: me, users: [me, him])

        my_permissions = PrivateTopicUserPermissions.new(private_topic, me)
        his_permissions = PrivateTopicUserPermissions.new(private_topic, him)
        their_permissions = PrivateTopicUserPermissions.new(private_topic, them)

        expect(my_permissions).to be_readable
        expect(his_permissions).to be_readable
        expect(their_permissions).not_to be_readable
      end
    end

    describe '#creatable?' do
      it 'for non-anonymous users' do
        user = create(:user)
        private_topic = build_stubbed(:private_topic, user: user)
        expect(PrivateTopicUserPermissions.new(private_topic, user)).to be_creatable
        expect(PrivateTopicUserPermissions.new(private_topic, Thredded::NullUser.new)).not_to be_creatable
      end
    end
  end
end
