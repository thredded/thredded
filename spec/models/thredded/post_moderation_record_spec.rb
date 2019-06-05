# frozen_string_literal: true

require 'spec_helper'

module Thredded
 
  describe PostModerationRecord do
    context 'scopes' do
      let!(:approved_post) { create(:post, moderation_state: :approved) }
      let!(:blocked_post) { create(:post, moderation_state: :blocked) }
      let!(:pending_post) { create(:post, moderation_state: :pending_moderation) }
      let!(:user) { create(:user) }
      let!(:approved_post_own) { create(:post, moderation_state: :approved, user: user) }
      let!(:blocked_post_own) { create(:post, moderation_state: :blocked, user: user) }
      let!(:pending_post_own) { create(:post, moderation_state: :pending_moderation, user: user) }

      it 'it has working scope: preload_first_topic_post' do
        expect { Thredded::PostModerationRecord.preload_first_topic_post }.not_to raise_error
      end
    end
  end

end
