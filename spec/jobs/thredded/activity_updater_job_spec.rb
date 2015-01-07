require 'timecop'
require 'spec_helper'

module Thredded
  describe ActivityUpdaterJob do
    it 'updates a users activity' do
      march_1 = Chronic.parse('Mar 1 2014 at 1:00pm')
      march_2 = Chronic.parse('Mar 2 2014 at 2:00pm')

      Timecop.freeze(march_1) do
        @role = create(:role)
        @user = @role.user
        @messageboard = @role.messageboard
      end

      Timecop.freeze(march_2) do
        Thredded::ActivityUpdaterJob.queue.update_user_activity(
          'messageboard_id' => @messageboard.id,
          'user_id' => @user.id
        )
      end

      expect(@role.reload.last_seen).to eq(march_2)
    end
  end
end
