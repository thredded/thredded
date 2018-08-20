# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe MessageboardGroupView, thredded_reset: [:@messageboards_order] do
    before { Thredded.messageboards_order = :position }

    describe '.groups' do
      context 'in one group' do
        let(:group) { create(:messageboard_group) }
        let(:messageboard1) { create(:messageboard, name: 'one', position: 1, group: group) }
        let(:messageboard2) { create(:messageboard, name: 'two', position: 2, group: group) }
        let(:messageboard3) { create(:messageboard, name: 'three', position: 3, group: group) }

        before do
          messageboard1 && messageboard3 && messageboard1
        end

        it 'retrieves messageboards in order' do
          expected_messageboards = [messageboard1, messageboard2, messageboard3]
          expect(MessageboardGroupView.grouped(Messageboard.all).first.messageboards.map(&:name))
            .to eq(expected_messageboards.map(&:name))
        end

        it 'retrieves them in groups' do
          expect(MessageboardGroupView.grouped(Messageboard.all).length).to eq(1)
        end
      end

      context 'with different groups' do
        let(:group1) { create(:messageboard_group, name: 'one', position: 1) }
        let(:group2) { create(:messageboard_group, name: 'two', position: 2) }
        let(:group3) { create(:messageboard_group, name: 'three', position: 3) }
        let(:messageboard_group1) { create(:messageboard, group: group1) }
        let(:messageboard_group2) { create(:messageboard, group: group2) }
        let(:messageboard_group3) { create(:messageboard, group: group3) }

        before do
          messageboard_group1
          messageboard_group3
          messageboard_group2
        end

        context 'when messageboards_order is position' do
          before { Thredded.messageboards_order = :position }

          it 'retrieves them with groups in correct order' do
            expected_groups = [group1, group2, group3]
            expect(MessageboardGroupView.grouped(Messageboard.all).map(&:group).map(&:name))
              .to eq(expected_groups.map(&:name))
            expect(MessageboardGroupView.grouped(Messageboard.all).map(&:group)).to eq(expected_groups)
          end

          context 'with messageboard with no group' do
            let(:messageboard_with_no_group) { create(:messageboard, group: nil, name: 'with no group') }

            before { messageboard_with_no_group }

            it 'has messageboards with no group first' do
              expected_groups = [nil, group1, group2, group3]
              expect(MessageboardGroupView.grouped(Messageboard.all).map(&:group).map { |mg| mg.try(:name) })
                .to eq(expected_groups.map { |mg| mg.try(:name) })
            end
          end
        end
      end
    end
  end
end
