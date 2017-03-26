# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe UserMessageboardPreference do
    let(:user) { create(:user) }

    describe 'autofollow' do
      it 'inherits `auto_follow_topics: true` from user_preference for a new record' do
        user.thredded_user_preference.update(auto_follow_topics: true)
        expect(UserMessageboardPreference.new(user: user, messageboard: create(:messageboard)).auto_follow_topics)
          .to eq true
      end

      it 'inherits `auto_follow_topics: false` from user_preference for a new record' do
        user.thredded_user_preference.update(auto_follow_topics: false)
        expect(UserMessageboardPreference.new(user: user, messageboard: create(:messageboard)).auto_follow_topics)
          .to eq false
      end
    end
  end
end
