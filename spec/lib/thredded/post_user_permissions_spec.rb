require 'spec_helper'
require 'thredded/post_user_permissions'

module Thredded
  describe PostUserPermissions do
    describe '#manageable?' do
      it 'can be managed by the user who started it' do
        user = build_stubbed(:user)
        post = build_stubbed(:post, user: user)
        user_details = UserDetail.new
        permissions = PostUserPermissions.new(post, user, user_details)

        permissions.should be_manageable
      end

      it 'can be managed by superadmin' do
        user = build_stubbed(:user)
        post = build_stubbed(:post, user: user)
        user_details = build_stubbed(:user_detail, superadmin: true)
        permissions = PostUserPermissions.new(post, user, user_details)

        permissions.should be_manageable
      end
    end
  end
end

