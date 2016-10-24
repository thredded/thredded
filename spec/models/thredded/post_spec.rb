# frozen_string_literal: true
require 'spec_helper'

module Thredded
  context 'when a parent user is nil' do
    describe Post, '#user_email' do
      it 'is nil' do
        post = build_stubbed(:post, user: nil)

        expect(post.user_email).to eq nil
      end
    end
  end

  describe Post, '#create' do
    it 'notifies anyone @ mentioned in the post' do
      mail = double('Thredded::PostMailer.post_notification(...)', deliver_now: true)

      expect(Thredded::PostMailer).to receive(:post_notification).with(1, ['joel@example.com']).and_return(mail)

      messageboard = create(:messageboard)
      joel = create(:user, name: 'joel', email: 'joel@example.com')
      create(
        :user_messageboard_preference,
        user: joel,
        messageboard: messageboard,
        follow_topics_on_mention: true
      )

      expect(mail).to receive(:deliver_now)

      create(:post, id: 1, content: 'hi @joel', messageboard: messageboard)
    end

    it 'updates the parent topic with the latest post author' do
      joel  = create(:user)
      topic = create(:topic)
      create(:post, user: joel, postable: topic)

      expect(topic.reload.last_user).to eq joel
    end

    it "increments the topic's and user's post counts" do
      joel = create(:user)
      joel_details = create(:user_detail, user: joel)
      topic = create(:topic)
      create_list(:post, 3, postable: topic, user: joel)

      expect(topic.reload.posts_count).to eq 3
      expect(joel_details.reload.posts_count).to eq 3
    end

    it 'updates the topic updated_at field to that of the new post' do
      joel  = create(:user)
      topic = create(:topic)
      future_time = 3.hours.from_now
      create(:post, postable: topic, user: joel, content: 'posting here')
      travel_to future_time do
        create(:post, postable: topic, user: joel, content: 'posting more')
      end

      expect(topic.updated_at.to_s).to eq future_time.to_s
    end

    it 'sets the post user email on creation' do
      shaun = create(:user)
      topic = create(:topic, last_user: shaun)
      post = create(:post, user: shaun, postable: topic)

      expect(post.user_email).to eq post.user.email
    end

    it 'creates a follow for creator' do
      shaun = create(:user)
      topic = create(:topic)

      expect { create(:post, user: shaun, postable: topic) }
        .to change { shaun.thredded_topic_follows.reload.count }.from(0).to(1)
      expect(Thredded::UserTopicFollow.last).to be_posted
    end

    it "doesn't create a follow if creator already has a follow" do
      shaun = create(:user)
      topic = create(:topic)
      create(:user_topic_follow, user_id: shaun.id, topic_id: topic.id)

      expect { create(:post, user: shaun, postable: topic) }
        .to_not change { shaun.thredded_topic_follows.reload.count }.from(1)
    end

    it 'creates a follow for a mentioned user' do
      messageboard = create(:messageboard)
      joel = create(:user, name: 'joel', email: 'joel@example.com')
      create(:user_messageboard_preference, user: joel, messageboard: messageboard, follow_topics_on_mention: true)

      expect { create(:post, content: 'hi @joel', messageboard: messageboard) }
        .to change { joel.thredded_topic_follows.reload.count }.from(0).to(1)
    end

    it 'notifies followers of new post' do
      joel = create(:user, name: 'joel', email: 'joel@example.com')
      topic = create(:topic)
      create(:user_topic_follow, user_id: joel.id, topic_id: topic.id)
      shaun = create(:user)
      expect { @post = create(:post, user: shaun, postable: topic) }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
      notified_emails = @post.post_notifications.map(&:email)
      expect(notified_emails).to eq(['joel@example.com'])
    end
  end

  describe Post, '#destroy' do
    it 'updates the topic last_post_at field to that of the last post' do
      user_1 = create(:user)
      user_2 = create(:user)
      topic = travel_to 1.hour.ago do
        create(:topic, with_posts: 1)
      end
      post_1 = create(:post, postable: topic, user: user_1, content: 'posting more')
      future_time = 3.hours.from_now
      travel_to future_time do
        post_2 = create(:post, postable: topic, user: user_2, content: 'posting more')
        expect(topic.updated_at.to_s).to eq post_2.created_at.to_s
        expect(topic.last_user).to eq user_2
        post_2.destroy
      end
      expect(topic.last_post_at.to_s).to eq post_1.created_at.to_s
      expect(topic.last_user).to eq user_1
    end
  end

  describe Post, 'ContentModerationState' do
    context 'inherits the moderation state from user when created' do
      it 'when the user is pending_moderation (default)' do
        expect(create(:post)).to be_pending_moderation
      end

      it 'when the user is approved' do
        expect(create(:post, user: create(:user, :approved))).to be_approved
      end

      it 'when the user is blocked' do
        expect(create(:post, user: create(:user, :blocked))).to be_blocked
      end
    end
    context 'visibility' do
      let!(:approved_post) { create(:post, moderation_state: :approved) }
      let!(:blocked_post) { create(:post, moderation_state: :blocked) }
      let!(:pending_post) { create(:post, moderation_state: :pending_moderation) }
      let!(:user) { create(:user) }
      let!(:approved_post_own) { create(:post, moderation_state: :approved, user: user) }
      let!(:blocked_post_own) { create(:post, moderation_state: :blocked, user: user) }
      let!(:pending_post_own) { create(:post, moderation_state: :pending_moderation, user: user) }

      context 'when Thredded.content_visible_while_pending_moderation' do
        around { |ex| with_thredded_setting(:content_visible_while_pending_moderation, true, &ex) }

        it '#moderation_state_visible_to_all? is true only for approved and pending posts' do
          expect(approved_post).to be_moderation_state_visible_to_all
          expect(blocked_post).not_to be_moderation_state_visible_to_all
          expect(pending_post).to be_moderation_state_visible_to_all
        end

        it '.moderation_state_visible_to_user(anonymous_user) shows approved and pending posts' do
          expect(Post.moderation_state_visible_to_user(Thredded::NullUser.new).to_a)
            .to match_array([approved_post_own, approved_post,
                             pending_post_own, pending_post])
        end

        it '.moderation_state_visible_to_user(user) shows own posts and approved and pending posts by other users' do
          expect(Post.moderation_state_visible_to_user(user).to_a)
            .to match_array([approved_post_own, approved_post,
                             blocked_post_own,
                             pending_post_own, pending_post])
        end
      end

      context 'when not Thredded.content_visible_while_pending_moderation' do
        around { |ex| with_thredded_setting(:content_visible_while_pending_moderation, false, &ex) }

        it '#moderation_state_visible_to_all? is true only for approved posts' do
          expect(approved_post).to be_moderation_state_visible_to_all
          expect(blocked_post).not_to be_moderation_state_visible_to_all
          expect(pending_post).not_to be_moderation_state_visible_to_all
        end

        it '.moderation_state_visible_to_user(anonymous_user) shows only approved posts' do
          expect(Post.moderation_state_visible_to_user(Thredded::NullUser.new).to_a)
            .to match_array([approved_post_own, approved_post])
        end

        it '.moderation_state_visible_to_user(users) shows all own posts and approved posts by other users' do
          expect(Post.moderation_state_visible_to_user(user).to_a)
            .to match_array([approved_post_own, approved_post,
                             blocked_post_own,
                             pending_post_own])
        end
      end
    end
  end

  describe Post, '#page' do
    let(:topic) { create :topic }
    subject { post.page(per_page: 1, user: NullUser.new) }
    let(:post) { create(:post, postable: topic, id: 100) }
    it 'for sole post' do
      expect(subject).to eq(1)
    end
    it 'for two posts' do
      travel_to 1.hour.ago do
        create(:post, postable: topic, id: 99)
      end
      expect(subject).to eq(2)
    end
    it 'respects policy' do
      policy = double(PostPolicy::Scope)
      expect(PostPolicy::Scope).to receive(:new).and_return(policy)
      expect(policy).to receive(:resolve).and_return(Post.none)
      travel_to 1.hour.ago do
        create(:post, postable: topic, id: 99)
      end
      expect(subject).to eq(1)
    end
    describe 'with different per_page' do
      subject { post.page(per_page: 2, user: NullUser.new) }
      it 'respects per' do
        travel_to 1.hour.ago do
          create(:post, postable: topic, id: 99)
        end
        expect(subject).to eq(1)
      end
    end
    it 'with  previous posts with disordered ids' do
      travel_to 2.hours.ago do
        create(:post, postable: topic, id: 101)
      end
      travel_to 1.hour.ago do
        create(:post, postable: topic, id: 99)
      end
      expect(subject).to eq(3)
    end
  end
end
