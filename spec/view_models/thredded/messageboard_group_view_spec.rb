# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe MessageboardGroupView, thredded_reset: [:@@messageboards_order] do
    describe '.groups' do
      context 'in one group' do
        let(:group) { create(:messageboard_group) }
        let(:old_messageboard_with_old_topic) { create(:messageboard, created_at: one_week_ago, name: 'old',
          group: group) }
        let(:antique_messageboard_with_recent_topic) { create(:messageboard, created_at: one_year_ago,
          name: 'antique/recent', group: group) }
        let(:current_messageboard) { create(:messageboard, name: 'current', group: group) }
        let(:old_topic) { create(:topic, updated_at: one_week_ago, messageboard: old_messageboard_with_old_topic) }
        let(:recent_topic) { create(:topic, updated_at: one_day_ago, messageboard: antique_messageboard_with_recent_topic) }
        let(:current_topic) { create(:topic, updated_at: one_minute_ago, messageboard: current_messageboard) }
        let!(:one_year_ago) { 1.year.ago }
        let!(:one_week_ago) { 1.week.ago }
        let!(:one_day_ago) { 1.day.ago }
        let!(:one_minute_ago) { 1.minute.ago }
        before do
          travel_to(one_week_ago) { old_topic }
          travel_to(one_day_ago) { recent_topic }
          travel_to(one_minute_ago) { current_topic }
          current_messageboard.update_attributes!(last_topic_id: current_topic.id)
          old_messageboard_with_old_topic.update_attributes!(last_topic_id: old_topic.id)
          antique_messageboard_with_recent_topic.update_attributes!(last_topic_id: recent_topic.id)
        end

        context "when messageboards_order is created_at_asc" do
          before { Thredded.messageboards_order = :created_at_asc }
          it 'retrieves messageboards in order' do
            expected_messageboards = [antique_messageboard_with_recent_topic, old_messageboard_with_old_topic, current_messageboard, ]
            expect(MessageboardGroupView.grouped(Messageboard.all).first.messageboards.map(&:name)).to eq(expected_messageboards.map(&:name))
          end
        end

        context "when messageboards_order is last_post_at_desc" do
          before { Thredded.messageboards_order = :last_post_at_desc }
          it 'retrieves messageboards in order' do
            expected_messageboards = [current_messageboard, antique_messageboard_with_recent_topic, old_messageboard_with_old_topic]
            expect(MessageboardGroupView.grouped(Messageboard.all).first.messageboards.map(&:name)).to eq(expected_messageboards.map(&:name))
          end
        end

        it 'retrieves them in groups' do
          expect(MessageboardGroupView.grouped(Messageboard.all).length).to eq(1)
        end
      end

      context 'with different groups' do
        let(:group_a_recent) { create(:messageboard_group, name: 'Alpha', created_at: 1.day.ago) }
        let(:group_b_current) { create(:messageboard_group, name: 'Bravo', created_at: 1.minute.ago) }
        let(:group_x_antique) { create(:messageboard_group, name: 'X Ray', created_at: 1.year.ago) }
        let(:messageboard_group_a) { create(:messageboard, group: group_a_recent) }
        let(:messageboard_group_b) { create(:messageboard, group: group_b_current) }
        let(:messageboard_group_x) { create(:messageboard, group: group_x_antique) }

        before do
          messageboard_group_a
          messageboard_group_x
          messageboard_group_b
        end

        context "when messageboards_order is created_at_asc" do
          before { Thredded.messageboards_order = :created_at_asc }

          it 'retrieves them in groups in correct order' do
            expected_groups = [group_x_antique, group_a_recent, group_b_current]
            expect(MessageboardGroupView.grouped(Messageboard.all).map(&:group).map(&:name)).to eq(expected_groups.map(&:name))
            expect(MessageboardGroupView.grouped(Messageboard.all).map(&:group)).to eq(expected_groups)
          end
        end

        context "when messageboards_order is last_post_at_desc" do
          before { Thredded.messageboards_order = :last_post_at_desc }

          it 'retrieves them in groups in correct order' do
            expected_groups = [group_a_recent, group_b_current, group_x_antique]
            expect(MessageboardGroupView.grouped(Messageboard.all).map(&:group)).to eq(expected_groups)
          end
        end
      end
    end
  end
end
