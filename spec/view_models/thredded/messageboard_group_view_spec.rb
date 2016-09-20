# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe MessageboardGroupView do
    describe '.groups' do
      context 'in one group' do
        let(:group) { create(:messageboard_group) }
        let(:old_messageboard) { create(:messageboard, name: 'old', group: group) }
        let(:recent_messageboard) { create(:messageboard, name: 'recent', group: group) }
        let(:current_messageboard) { create(:messageboard, name: 'current', group: group) }
        let(:old_topic) { create(:topic, updated_at: one_week_ago, messageboard: old_messageboard) }
        let(:recent_topic) { create(:topic, updated_at: one_day_ago, messageboard: recent_messageboard) }
        let(:current_topic) { create(:topic, updated_at: one_minute_ago, messageboard: current_messageboard) }
        let(:one_week_ago) { 1.week.ago }
        let(:one_day_ago) { 1.day.ago }
        let(:one_minute_ago) { 1.minute.ago }
        before do
          travel_to(one_week_ago) { old_topic }
          travel_to(one_day_ago) { recent_topic }
          travel_to(one_minute_ago) { current_topic }
          current_messageboard.update_attributes!(last_topic_id: current_topic.id)
          old_messageboard.update_attributes!(last_topic_id: old_topic.id)
          recent_messageboard.update_attributes!(last_topic_id: recent_topic.id)
        end

        it 'retrieves messageboards in order' do
          expected_messageboards = [current_messageboard, recent_messageboard, old_messageboard]
          expect(MessageboardGroupView.grouped(Messageboard.all).first.messageboards).to eq(expected_messageboards)
        end

        it 'retrieves them in groups' do
          expect(MessageboardGroupView.grouped(Messageboard.all).length).to eq(1)
        end
      end

      context 'with different groups' do
        let(:group_a) { create(:messageboard_group, name: 'Alpha') }
        let(:group_b) { create(:messageboard_group, name: 'Bravo') }
        let(:group_x) { create(:messageboard_group, name: 'X Ray') }
        let(:messageboard_group_a) { create(:messageboard, group: group_a, updated_at: 10.minutes.ago) }
        let(:messageboard_group_b) { create(:messageboard, group: group_b, updated_at: 50.minutes.ago) }
        let(:messageboard_group_x) { create(:messageboard, group: group_x, updated_at: 20.minutes.ago) }

        before do
          messageboard_group_a
          messageboard_group_x
          messageboard_group_b
        end

        it 'retrieves them in groups' do
          expected_groups = [group_a, group_b, group_x]
          expect(MessageboardGroupView.grouped(Messageboard.all).map(&:group)).to eq(expected_groups)
        end
      end
    end
  end
end
