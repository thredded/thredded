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

    it 'orders by number of topics, descending' do
      create(:messageboard, topics_count: 500)
      lots       = create(:messageboard, topics_count: 1000)
      all_boards = Messageboard.all

      expect(all_boards.first).to eq lots
      expect(all_boards.last).to eq @messageboard
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

  describe '#update_last_topic!' do
    let(:messageboard) { create(:messageboard) }
    let(:new_topic) { create(:topic, messageboard: messageboard) }
    let(:the_last_topic) { create(:topic, messageboard: messageboard) }
    let(:an_hour_ago) { 1.hour.ago }
    before do
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
  end
end
