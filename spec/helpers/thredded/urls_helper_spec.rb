# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe UrlsHelper do
    describe '.mark_unread_path' do
      let(:user) { create(:user) }
      let(:private_topic) { create(:private_topic, users: [user, other_user]) }
      let(:private_post) { create(:private_post, postable: private_topic) }
      let(:other_user) { create(:user) }

      it 'works with private posts' do
        expect(UrlsHelper.mark_unread_path(private_post)).to start_with('/thredded/action')
      end
    end
  end
end
