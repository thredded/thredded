# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe PrivatePost do
    let(:private_topic) { create(:private_topic, user: sally, users: [jane, erik]) }
    let(:sally) { create(:user) }
    let(:jane) { create(:user) }
    let(:erik) { create(:user) }

    it 'notifies members on create' do
      private_post = build(:private_post, postable: private_topic, user: jane)
      notifier = double(NotifyPrivateTopicUsers)
      expect(NotifyPrivateTopicUsers).to receive(:new).with(private_post).and_return(notifier)
      expect(notifier).to receive(:run)
      private_post.save!
    end
  end
end
