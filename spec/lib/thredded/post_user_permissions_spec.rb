require 'spec_helper'
require 'thredded/post_user_permissions'

module Thredded
  describe PostUserPermissions do
    describe '#editable?' do
      it 'can be edited by the user who started it' do
        user = build_stubbed(:user)
        post = build_stubbed(:post, user: user)
        user_details = UserDetail.new
        permissions = PostUserPermissions.new(post, user, user_details)

        expect(permissions).to be_editable
      end
    end

    describe '#manageable?' do
      it 'can be managed by the user who started it' do
        user = build_stubbed(:user)
        post = build_stubbed(:post, user: user)
        user_details = UserDetail.new
        permissions = PostUserPermissions.new(post, user, user_details)

        expect(permissions).to be_manageable
      end

      it 'can be managed by an admin' do
        user = build_stubbed(:user, admin: true)
        post = build_stubbed(:post, user: user)
        user_details = build_stubbed(:user_detail)
        permissions = PostUserPermissions.new(post, user, user_details)

        expect(permissions).to be_manageable
      end
    end

    describe '#creatable?' do
      it 'can create a post if you are allowed to create a topic' do
        messageboard_permissions = double('postable?' => true)
        expect(MessageboardUserPermissions).to receive(:new).and_return(messageboard_permissions)
        expect(post_permissions).to be_creatable
      end

      it 'can NOT create a post if you are not allowed to create a topic' do
        messageboard_permissions = double('postable?' => false)
        expect(MessageboardUserPermissions).to receive(:new).and_return(messageboard_permissions)
        expect(post_permissions).not_to be_creatable
      end

      it 'cannot create a post if the topic is locked' do
        topic_permissions = double('creatable?' => true)
        allow(TopicUserPermissions).to receive_messages(new: topic_permissions)

        user = build_stubbed(:user)
        topic = build_stubbed(:topic, :locked)
        post = build_stubbed(:post, user: user, postable: topic)
        user_details = UserDetail.new
        permissions = PostUserPermissions.new(post, user, user_details)

        expect(permissions).not_to be_creatable
      end

      def post_permissions
        user = build_stubbed(:user)
        post = build_stubbed(:post, user: user)
        user_details = UserDetail.new
        PostUserPermissions.new(post, user, user_details)
      end
    end
  end
end
