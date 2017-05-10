# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe UserPreferencesForm do
    let(:user) { create(:user) }

    context 'autofollow' do
      let(:default_auto_follow) { UserPreference.new.auto_follow_topics }

      it 'changed: updates messageboard preferences' do
        messageboard_preference = create(:user_messageboard_preference, user: user)
        expect(messageboard_preference.auto_follow_topics).to eq default_auto_follow
        new_value = !default_auto_follow
        UserPreferencesForm.new(user: user, params: { auto_follow_topics: new_value }).save
        expect(messageboard_preference.reload.auto_follow_topics).to eq new_value
      end

      it 'not changed: messageboard preferences intact' do
        board_value = !default_auto_follow
        messageboard_preference = create(:user_messageboard_preference, user: user, auto_follow_topics: board_value)
        expect(messageboard_preference.auto_follow_topics).to eq board_value
        expect(user.thredded_user_preference.auto_follow_topics).to_not eq board_value
        UserPreferencesForm.new(user: user).save
        expect(messageboard_preference.reload.auto_follow_topics).to eq board_value
        expect(user.thredded_user_preference.reload.auto_follow_topics).to_not eq board_value
      end
    end
  end
end
