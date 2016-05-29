# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe PrivateTopic, '.with_read_states' do
    let(:user) { create(:user) }
    let!(:private_topic) { create(:private_topic) }

    context 'when unread' do
      it 'returns nulls ' do
        first = PrivateTopic.all.with_read_states(user).first
        expect(first[0]).to eq(private_topic)
        expect(first[1]).to be_an_instance_of(Thredded::NullUserTopicReadState)
      end
    end

    context 'when read' do
      let!(:read_state) { create(:user_private_topic_read_state, user: user, postable: private_topic, read_at: 1.day.ago) }
      it 'returns read states' do
        first = PrivateTopic.all.with_read_states(user).first
        expect(first[0]).to eq(private_topic)
        expect(first[1]).to eq(read_state)
      end
    end
  end
end
