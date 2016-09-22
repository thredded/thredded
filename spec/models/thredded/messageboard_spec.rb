# frozen_string_literal: true
require 'spec_helper'

module Thredded
  describe Messageboard do
    before(:each) do
      @messageboard = create(:messageboard, topics_count: 10)
    end

    it 'generates the slug' do
      messageboard = create(:messageboard, name: 'Super Friends')

      expect(messageboard.slug).to eq 'super-friends'
    end

    it 'returns only open messageboards' do
      closed     = create(:messageboard, closed: true)
      all_boards = Messageboard.all

      expect(all_boards).to include(@messageboard)
      expect(all_boards).not_to include(closed)
    end

    describe '#recently_active_users' do
      it 'returns users active for a messageboard' do
        messageboard   = create(:messageboard)
        active_user    = create(:user)
        _inactive_user = create(:user)
        Thredded::ActivityUpdaterJob.perform_later(
          active_user.id,
          messageboard.id
        )

        expect(messageboard.recently_active_users).to eq [active_user]
      end
    end

    describe '.find_by_slug' do
      it 'finds the messageboard according to the slug' do
        messageboard = create(:messageboard, name: 'A messageboard')

        expect(Messageboard.find_by_slug('a-messageboard')).to eq messageboard
      end

      context 'when a messageboard is not found' do
        it 'returns nil' do
          expect(Messageboard.find_by_slug('rubbish')).to eq nil
        end
      end
    end

    describe '#last_topic' do
      context 'when Thredded.content_visible_while_pending_moderation' do
        around { |ex| with_thredded_setting(:content_visible_while_pending_moderation, false, &ex) }

        it 'returns the last updated topic' do
          messageboard = create(:messageboard)
          expect(messageboard.last_topic).to be_nil
          topic_a = create(:topic, title: 'A', with_posts: 1, messageboard: messageboard, moderation_state: :approved)
          expect(messageboard.last_topic).to eq topic_a
          new_post_in_a = travel_to 1.hour.from_now do
            create(:post, postable: topic_a, moderation_state: :pending_moderation)
          end
          topic_b = create(:topic, title: 'B', with_posts: 1, messageboard: messageboard, moderation_state: :approved)
          expect(messageboard.reload.last_topic).to eq topic_b
          Thredded::ModeratePost.run!(post: new_post_in_a, moderation_state: :approved, moderator: topic_a.user)
          expect(messageboard.reload.last_topic).to eq topic_a
          topic_c = travel_to 2.hours.from_now do
            create(:topic, title: 'C', with_posts: 1, messageboard: messageboard, moderation_state: :pending_moderation)
          end
          expect(messageboard.reload.last_topic).to eq topic_a
          Thredded::ModeratePost.run!(post: topic_c.posts.last, moderation_state: :approved, moderator: topic_a.user)
          expect(messageboard.reload.last_topic).to eq topic_c
        end
      end
    end
  end

  describe '#update_last_topic!', thredded_reset: [:@@messageboards_order] do
    let(:messageboard) { create(:messageboard) }
    let(:new_topic) { create(:topic, messageboard: messageboard) }
    let(:the_last_topic) { create(:topic, messageboard: messageboard) }
    let!(:an_hour_ago) { 1.hour.ago }
    before do
      Thredded.messageboards_order = :position
      travel_to(an_hour_ago) { messageboard.reload.update!(last_topic: the_last_topic) }
      expect(messageboard.updated_at).to be_within(10.seconds).of(an_hour_ago)
    end
    it 'when last topic changes, updated_at changes' do
      expect do
        create(:post, postable: new_topic)
      end.to change { messageboard.reload.updated_at }.to be_within(10.seconds).of(Time.zone.now)
    end
    it "when last topic doesn't change, updated_at doesn't change" do
      expect do
        create(:post, postable: the_last_topic)
      end.not_to change { messageboard.reload.updated_at }
    end

    describe 'adjusting position' do
      let!(:ten_minutes_ago) { 10.minutes.ago }
      subject do
        travel_to(ten_minutes_ago) { create(:post, postable: new_topic) }
      end
      context 'when messageboards_order :position' do
        before { Thredded.messageboards_order = :position }
        it "doesn't change position" do
          expect { subject }.not_to change { messageboard.reload.position }
        end
      end
      context 'when messageboards_order :last_post_at_desc' do
        before { Thredded.messageboards_order = :last_post_at_desc }
        it 'changes position' do
          expect { subject }.to change { messageboard.reload.position }
        end
      end
    end
  end

  describe '#recalculate_position', thredded_reset: [:@@messageboards_order] do
    let(:messageboard) { create(:messageboard, created_at: two_weeks_ago).tap { |m| m.update_column(:position, 0) } }
    let!(:two_weeks_ago) { 2.weeks.ago }
    subject { messageboard.recalculate_position }
    context 'when messageboards_order :position' do
      before { Thredded.messageboards_order = :position }
      it "doesn't change position" do
        expect { subject }.not_to change { messageboard.position }
      end
    end
    context 'when messageboards_order :last_post_at_desc' do
      before { Thredded.messageboards_order = :last_post_at_desc }
      context 'with no topics' do
        it 'changes position' do
          expect { subject }.to change { messageboard.position }.to(-messageboard.created_at.to_i)
        end
      end
      context 'with a topic' do
        let!(:topic) { build_stubbed(:topic) }
        let!(:three_minutes_ago) { 3.minutes.ago }
        it 'changes position' do
          expect(messageboard).to receive(:last_topic).at_least(:once).and_return(topic)
          expect(topic).to receive(:last_post_at).at_least(:once).and_return(three_minutes_ago)
          expect { subject }.to change { messageboard.position }.to(-three_minutes_ago.to_i)
        end
      end
    end
  end

  describe '.recalculate_positions', thredded_reset: [:@@messageboards_order] do
    subject { Messageboard.recalculate_positions! }
    let(:messageboard1) { create(:messageboard, position: 1) }
    let(:messageboard2) { create(:messageboard, position: 2) }
    let(:messageboard3) { create(:messageboard, position: 3) }
    context 'when messageboards_order :position' do
      before do
        Thredded.messageboards_order = :position
        expect(messageboard1.position).to eq(1)
      end
      it "doesn't change position" do
        expect { subject }
          .not_to change { [messageboard1, messageboard2, messageboard3].map { |m| m.reload.position } }
        expect(Messageboard.ordered).to eq([messageboard1, messageboard2, messageboard3])
      end
    end
    context 'when messageboards_order :last_post_at_desc' do
      let(:messageboard1) { create(:messageboard, name: 'one', created_at: 2.years.ago) }
      let(:messageboard2) { create(:messageboard, name: 'two', created_at: 1.year.ago) }
      let(:messageboard3) { create(:messageboard, name: 'three', created_at: one_week_ago) }
      let(:one_week_ago) { 1.week.ago }
      let(:one_day_ago) { 1.day.ago }
      let(:one_hour_ago) { 1.hour.ago }
      let(:topic2) { create(:topic, last_post_at: one_day_ago, messageboard: messageboard2) }
      let(:topic1) { create(:topic, last_post_at: one_hour_ago, messageboard: messageboard1) }
      before do
        Thredded.messageboards_order = :last_post_at_desc
        messageboard2 && messageboard3 && messageboard1
        topic2.update_column(:last_post_at, one_day_ago)
        topic1.update_column(:last_post_at, one_hour_ago)
        messageboard2.update_column(:last_topic_id, topic2.id)
        messageboard1.update_column(:last_topic_id, topic1.id)
      end

      it 'does change position' do
        expect { subject }
          .to change { [messageboard1, messageboard2, messageboard3].map { |m| m.reload.position } }
        expect(Messageboard.ordered.map(&:name))
          .to eq([messageboard1, messageboard2, messageboard3].map(&:name))
      end
    end

    context 'when messageboards_order :topics_count_desc' do
      before { Thredded.messageboards_order = :topics_count_desc }
      let(:messageboard1) { create(:messageboard, topics_count: 100).tap { |m| m.update_column(:position, 0) } }
      let(:messageboard2) { create(:messageboard, topics_count: 10).tap { |m| m.update_column(:position, 0) } }
      let(:messageboard3) { create(:messageboard, topics_count: 1).tap { |m| m.update_column(:position, 0) } }

      before do
        Thredded.messageboards_order = :topics_count_desc
        messageboard2 && messageboard3 && messageboard1
        expect(messageboard1.position).to eq(0)
      end

      it 'does change position' do
        expect { subject }
          .to change { [messageboard1, messageboard2, messageboard3].map { |m| m.reload.position } }
        expect(messageboard1.position).to eq(-messageboard1.topics_count)
        expect(Messageboard.ordered).to eq([messageboard1, messageboard2, messageboard3])
      end
    end
  end

  describe '#position (default)', thredded_reset: [:@@messageboards_order] do
    context 'when messageboards_order :position' do
      before do
        Thredded.messageboards_order = :position
      end

      it 'has a default position of the created at' do
        messageboard = create(:messageboard)
        expect(messageboard.position).to be_within(10).of(messageboard.created_at.to_i)
      end

      it "can define a value for position which won't change" do
        messageboard = create(:messageboard, position: 12)
        expect(messageboard.position).to eq(12)
      end
    end

    context 'when messageboards_order :last_post_at_desc' do
      before do
        Thredded.messageboards_order = :last_post_at_desc
      end

      it 'has a default position of the created at' do
        messageboard = create(:messageboard)
        expect(messageboard.position).to be_within(10).of(messageboard.created_at.to_i)
      end

      it "can't define a value for position" do
        messageboard = create(:messageboard, position: 12)
        expect(messageboard.position).to be_within(10).of(messageboard.created_at.to_i)
      end
    end

    context 'when messageboards_order :topics_count_desc' do
      before { Thredded.messageboards_order = :topics_count_desc }

      it 'has a default position of the created at' do
        messageboard = create(:messageboard, topics_count: 5)
        expect(messageboard.position).to eq(-5)
      end

      it "can't define a value for position" do
        messageboard = create(:messageboard, topics_count: 5, position: 12)
        expect(messageboard.position).to eq(-5)
      end
    end
  end
end
