require 'spec_helper'
require 'thredded/messageboard_user_permissions'

module Thredded
  describe MessageboardUserPermissions do
    describe '#readable?' do
      context 'when it is private' do
        let(:messageboard){  create(:messageboard, :private) }

        it 'is readable by members' do
          user = create(:user)
          messageboard.add_member(user)
          permissions = MessageboardUserPermissions.new(messageboard, user)
          permissions.should be_readable
        end

        it 'is not readable by non-members' do
          user = create(:user)
          permissions = MessageboardUserPermissions.new(messageboard, user)
          permissions.should_not be_readable
        end

        it 'is not readable by anonymous people' do
          user = Thredded::NullUser.new
          permissions = MessageboardUserPermissions.new(messageboard, user)
          permissions.should_not be_readable
        end
      end

      context 'when set to logged_in' do
        let(:messageboard){  create(:messageboard, :restricted_to_logged_in) }

        it 'is readable by members' do
          user = create(:user)
          messageboard.add_member(user)
          permissions = MessageboardUserPermissions.new(messageboard, user)
          permissions.should be_readable
        end

        it 'is readable by non-members' do
          user = create(:user)
          permissions = MessageboardUserPermissions.new(messageboard, user)
          permissions.should be_readable
        end

        it 'is not readable by anonymous people' do
          user = Thredded::NullUser.new
          permissions = MessageboardUserPermissions.new(messageboard, user)
          permissions.should_not be_readable
        end
      end

      context 'when it is public' do
        it 'is readable to anyone' do
          messageboard = build_stubbed(:messageboard, :public)
          user = Thredded::NullUser.new
          permissions = MessageboardUserPermissions.new(messageboard, user)
          permissions.should be_readable
        end
      end
    end
  end
end
