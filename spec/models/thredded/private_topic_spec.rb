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
      let!(:read_state) do
        create(:user_private_topic_read_state, user: user, postable: private_topic, read_at: 1.day.ago)
      end
      it 'returns read states' do
        first = PrivateTopic.all.with_read_states(user).first
        expect(first[0]).to eq(private_topic)
        expect(first[1]).to eq(read_state)
      end
    end
  end

  describe 'changes to private posts...' do
    let(:private_topic) { create(:private_topic) }

    context 'when a new post is added' do
      it 'changes updated_at' do
        expect { travel_to(1.day.from_now) { create(:private_post, postable: private_topic) } }
          .to change { private_topic.reload.updated_at }
      end

      it 'changes last_read_at' do
        expect { travel_to(1.day.from_now) { create(:private_post, postable: private_topic) } }
          .to change { private_topic.reload.last_post_at }
      end
    end

    context 'when a post is deleted' do
      let(:first_post) { create(:private_post, postable: private_topic) }
      let(:second_post) { create(:private_post, postable: private_topic) }
      before do
        travel_to(1.month.ago) { first_post }
        travel_to(1.hour.ago) { second_post }
      end

      it 'changes updated_at to just now' do
        expect { second_post.destroy }
          .to change { private_topic.reload.updated_at }.to be_within(10).of(Time.zone.now)
      end

      it 'changes last_read_at to first post' do
        expect { second_post.destroy }
          .to change { private_topic.reload.last_post_at }.to eq(first_post.created_at)
      end
    end

    context 'when an old post is edited' do
      before { travel_to(1.month.ago) { @post = create(:private_post, postable: private_topic) } }

      it 'does not change updated_at' do
        expect { @post.update_attributes(content: 'hi there') }
          .not_to change { @post.postable.reload.updated_at }
      end

      it 'does not change updated_at' do
        expect { @post.update_attributes(content: 'hi there') }
          .not_to change { @post.postable.reload.last_post_at }
      end
    end
  end
end
