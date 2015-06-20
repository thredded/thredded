require 'spec_helper'

module Thredded
  describe EnsureRoleExistsJob do
    it 'rescues from user not found' do
      messageboard = create(:messageboard)

      expect {
        Thredded::EnsureRoleExistsJob.queue.for_user_and_messageboard(
          999,
          messageboard.id,
        )
      }.not_to raise_error
    end

    it 'rescues from messageboard not found' do
      user = create(:user)

      expect {
        Thredded::EnsureRoleExistsJob.queue.for_user_and_messageboard(
          user.id,
          999,
        )
      }.not_to raise_error
    end
  end
end
