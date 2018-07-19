# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe ActivityUpdaterJob do
    it 'updates a users activity' do
      march_1 = Time.zone.parse('2014-03-01 13:00:00')
      march_2 = Time.zone.parse('2014-03-02 14:00:00')
      march_3 = Time.zone.parse('2014-03-03 14:00:00')

      travel_to march_1 do
        @user = create(:user)
        @messageboard = create(:messageboard)
      end

      travel_to march_2 do
        Thredded::ActivityUpdaterJob.perform_later(@user.id, @messageboard.id)
      end
      user_detail = Thredded::UserDetail.find_by!(user_id: @user.id)
      messageboard_user = Thredded::MessageboardUser.find_by!(
        thredded_messageboard_id: @messageboard.id, thredded_user_detail_id: user_detail.id
      )
      expect(user_detail.last_seen_at).to eq(march_2)
      expect(messageboard_user.last_seen_at).to eq(march_2)

      travel_to march_3 do
        Thredded::ActivityUpdaterJob.perform_later(@user.id, @messageboard.id)
      end
      expect(user_detail.reload.last_seen_at).to eq(march_3)
      expect(messageboard_user.reload.last_seen_at).to eq(march_3)
    end
  end
end
