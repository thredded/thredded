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

  describe PrivatePost, '#page' do
    let(:private_topic) { create(:private_topic, user: sally, users: [jane]) }
    let(:sally) { create(:user) }
    let(:jane) { create(:user) }
    subject { private_post.page(per_page: 1) }
    let(:private_post) { create(:private_post, postable: private_topic, id: 100) }
    it 'for sole private_post' do
      expect(subject).to eq(1)
    end
    it 'for two private_posts' do
      travel_to 1.hour.ago do
        create(:private_post, postable: private_topic, id: 99)
      end
      expect(subject).to eq(2)
    end
    describe 'with different per_page' do
      subject { private_post.page(per_page: 2) }
      it 'respects per' do
        travel_to 1.hour.ago do
          create(:private_post, postable: private_topic, id: 99)
        end
        expect(subject).to eq(1)
      end
    end
    it 'with previous posts with disordered ids' do
      travel_to 2.hours.ago do
        create(:private_post, postable: private_topic, id: 101)
      end
      travel_to 1.hour.ago do
        create(:private_post, postable: private_topic, id: 99)
      end
      expect(subject).to eq(3)
    end
  end
end
