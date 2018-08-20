# frozen_string_literal: true

require 'spec_helper'

describe Thredded::MessageboardGroup do
  it 'has a default position of the created at' do
    messageboard_group = create(:messageboard_group)
    expect(messageboard_group.position).to be_within(10).of(messageboard_group.created_at.to_i)
  end

  it "can define a value for position which won't change" do
    messageboard_group = create(:messageboard_group, position: 12)
    expect(messageboard_group.position).to eq(12)
  end

  describe '.ordered' do
    let(:messageboard_group1) { create(:messageboard_group, name: 'one', position: 8) }
    let(:messageboard_group2) { create(:messageboard_group, name: 'two', position: 24) }
    let(:messageboard_group3) { create(:messageboard_group, name: 'three', position: 235) }

    it 'by position' do
      messageboard_group2 && messageboard_group1 && messageboard_group3
      expect(described_class.ordered).to eq([messageboard_group1, messageboard_group2, messageboard_group3])
    end
  end
end
