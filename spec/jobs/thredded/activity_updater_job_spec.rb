require 'timecop'
require 'spec_helper'

module Thredded
  describe ActivityUpdaterJob do
    it 'updates a users activity' do
      march_1 = Chronic.parse('Mar 1 2014 at 1:00pm')
      march_2 = Chronic.parse('Mar 2 2014 at 2:00pm')

      Timecop.freeze(march_1) do
        @user_detail = create(:user_detail)
        @user = @user_detail.user
        @messageboard = create(:messageboard)
      end

      Timecop.freeze(march_2) do
        Thredded::ActivityUpdaterJob.perform_later(@user.id, @messageboard.id)
      end

      expect(@user_detail.reload.last_seen_at).to eq(march_2)
    end
  end
end
