# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe ActivityUpdaterJob do
    it 'updates a users activity' do
      march_1 = Time.zone.parse('2014-03-01 13:00:00')
      march_2 = Time.zone.parse('2014-03-02 14:00:00')

      travel_to march_1 do
        @user_detail = create(:user_detail)
        @user = @user_detail.user
        @messageboard = create(:messageboard)
      end

      travel_to march_2 do
        Thredded::ActivityUpdaterJob.perform_later(@user.id, @messageboard.id)
      end

      expect(@user_detail.reload.last_seen_at).to eq(march_2)
    end
  end
end
