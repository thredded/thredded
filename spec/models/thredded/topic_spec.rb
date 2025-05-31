# frozen_string_literal: true

require 'spec_helper'

module Thredded
  describe Topic, '.friendly_find!' do
    it 'finds the topic' do
      topic = create(:topic, title: 'Oh Hello')

      expect(Topic.friendly_find!('oh-hello')).to eq topic
    end

    it 'raises Thredded::Errors::TopicNotFound error' do
      expect { Topic.friendly_find!('rubbish') }
        .to raise_error(Thredded::Errors::TopicNotFound)
    end
  end

  describe Topic, '.search' do
    test_title = 'Xyzzy'

    # On MySQL, a transaction has to complete before the full text search index is updated
    before :all do
      @messageboard = create(:messageboard)
      @user = create(:user, name: 'glebm')
      @category = create(:category, name: 'anime', messageboard: @messageboard)
      _not_a_result = create(:topic)
      # On MySQL, if text is present in over 50% of the rows it won't be found. Create some dummy entries to avoid this.
      3.times { _not_a_result = create(:topic, messageboard: @messageboard) }
      defaults = {}
      @topic_with_user = create(:topic, user: @user, **defaults)
      @topic_with_category = create(:topic, categories: [@category], **defaults)
      @topic_with_category_and_user = create(:topic, categories: [@category], user: @user, **defaults)
      @topic_with_title = create(:topic, title: test_title, **defaults)
      @topic_with_title_and_category = create(:topic, title: test_title, categories: [@category], **defaults)
      @topic_with_title_and_user = create(:topic, title: test_title, user: @user, **defaults)
      @topic_with_title_and_category_and_user = create(
        :topic, title: test_title, categories: [@category], user: @user, **defaults
      )
    end

    after :all do
      DatabaseCleaner.clean_with(:truncation)
    end

    it 'with text' do
      expect(Topic.search_query(test_title).to_a).to(
        match_array([@topic_with_title, @topic_with_title_and_category, @topic_with_title_and_user,
                     @topic_with_title_and_category_and_user])
      )
    end

    it 'with "by:"' do
      expect(Topic.search_query("by:#{@user.name}").to_a).to(
        match_array([@topic_with_user, @topic_with_category_and_user, @topic_with_title_and_user,
                     @topic_with_title_and_category_and_user])
      )
    end

    it 'with "in:"' do
      expect(Topic.search_query("in:#{@category.name}").to_a).to(
        match_array([@topic_with_category, @topic_with_category_and_user, @topic_with_title_and_category,
                     @topic_with_title_and_category_and_user])
      )
    end

    it 'with "by:" and text' do
      expect(Topic.search_query("#{test_title} by:#{@user.name}").to_a).to(
        match_array([@topic_with_title_and_user, @topic_with_title_and_category_and_user])
      )
    end

    it 'with "in:" and text' do
      expect(Topic.search_query("#{test_title} in:#{@category.name}").to_a).to(
        match_array([@topic_with_title_and_category, @topic_with_title_and_category_and_user])
      )
    end

    it 'with "by:" and "in:" and text' do
      expect(Topic.search_query("#{test_title} by: #{@user.name} in:#{@category.name}").to_a).to(
        match_array([@topic_with_title_and_category_and_user])
      )
    end
  end

  describe Topic, '.with_read_and_follow_states' do
    let(:user) { create(:user) }
    let!(:topic) { create(:topic, with_posts: 2) }

    context 'when unread, unfollowed' do
      it 'returns nulls ' do
        first = Topic.all.with_read_and_follow_states(user).first
        expect(first[0]).to eq(topic)
        expect(first[1]).to be_an_instance_of(Thredded::NullUserTopicReadState)
        expect(first[2]).to be_falsey
      end
    end

    context 'when read' do
      let!(:read_state) do
        create(
          :user_topic_read_state, user: user, postable: topic,
                                  read_at: topic.posts.order_oldest_first.first.created_at
        )
      end

      it 'returns read states' do
        first = Topic.all.with_read_and_follow_states(user).first
        expect(first[0]).to eq(topic)
        expect(first[1]).to eq(read_state)
      end
    end

    context 'when followed' do
      let!(:follow) { create(:user_topic_follow, user: user, topic: topic) }

      it 'returns read states' do
        first = Topic.all.with_read_and_follow_states(user).first
        expect(first[0]).to eq(topic)
        expect(first[2]).to be_truthy
      end
    end
  end

  describe Topic, '.followed_by(user)' do
    subject(:followed_topics) { Topic.followed_by(user) }

    let(:user) { create(:user) }
    let(:topic) { create :topic }
    let(:follow_state) {}

    before do
      follow_state
    end

    context 'with following topic' do
      let(:follow_state) { UserTopicFollow.create!(user_id: user.id, topic_id: topic.id, reason: :manual) }

      it 'is included' do
        expect(followed_topics).to include(topic)
      end
    end

    context 'with not-following topic' do
      let(:follow_state) {}

      it 'is not included' do
        expect(followed_topics).not_to include(topic)
      end
      context 'when followed by someone else' do
        let(:follow_state) { UserTopicFollow.create!(user_id: create(:user).id, topic_id: topic.id, reason: :manual) }

        it 'is not included' do
          expect(followed_topics).not_to include(topic)
        end
      end
    end
  end

  describe Topic, '.unread_followed_by(user)' do
    subject(:unread_followed_topics) { Topic.unread_followed_by(user) }

    let(:user) { create(:user) }
    let(:topic) { create :topic, last_post_at: a_minute_ago }
    let(:post) { create :post, postable: topic }
    let(:read_state) {}
    let(:follow_state) {}
    let(:a_minute_ago) { 1.minute.ago }

    before do
      post
      read_state
      follow_state
    end

    def create_read_state(read_at, user_id: user.id)
      read_state = UserTopicReadState.new(
        user_id: user_id, messageboard_id: topic.messageboard_id, postable_id: topic.id, read_at: read_at
      )
      read_state.update!(read_state.calculate_post_counts)
    end

    context 'with following topic' do
      let(:follow_state) { UserTopicFollow.create!(user_id: user.id, topic_id: topic.id, reason: :manual) }

      context 'with no read state' do
        it 'is included' do
          expect(unread_followed_topics).to include(topic)
        end
      end

      context 'with read state not up to date' do
        let(:read_state) { create_read_state(1.day.ago) }

        it 'is included' do
          expect(unread_followed_topics).to include(topic)
        end
      end

      context 'with read state which is up to date' do
        let(:read_state) { create_read_state(topic.last_post_at) }

        it 'is not included' do
          expect(unread_followed_topics).not_to include(topic)
        end
      end

      context 'with read state for someone else' do
        let(:read_state) { create_read_state(topic.last_post_at, user_id: create(:user).id) }

        it 'is included' do
          expect(unread_followed_topics).to include(topic)
        end
      end

      context 'with mixture of other post' do
        before do
          create_list(:post, 3)
        end

        it 'has right count' do
          expect(unread_followed_topics.count).to eq(1)
        end
      end
    end

    context 'with not-following topic' do
      let(:follow_state) {}

      context 'with no read state' do
        it 'is not included' do
          expect(unread_followed_topics).not_to include(topic)
        end
      end

      context 'with read state not up to date' do
        let(:read_state) { create_read_state(1.day.ago) }

        it 'is not included' do
          expect(unread_followed_topics).not_to include(topic)
        end
      end

      context 'with read state which is up to date' do
        it 'is not included' do
          expect(unread_followed_topics).not_to include(topic)
        end
      end

      context 'when followed by someone else' do
        let(:follow_state) { UserTopicFollow.create!(user_id: create(:user).id, topic_id: topic.id, reason: :manual) }

        it 'is not included' do
          expect(unread_followed_topics).not_to include(topic)
        end
      end
    end
  end

  describe Topic, '#last_user' do
    it 'provides anon user object when user not avail' do
      topic = build_stubbed(:topic, last_user_id: 1000)

      expect(topic.last_user).to be_instance_of NullUser
    end

    it 'returns the last user to post to this thread' do
      user = build_stubbed(:user)
      topic = build_stubbed(:topic, last_user: user)

      expect(topic.last_user).to eq(user)
    end

    context 'when not Thredded.content_visible_while_pending_moderation' do
      around { |ex| with_thredded_setting(:content_visible_while_pending_moderation, false, &ex) }

      it 'for an approved topic, the last user is the user of the last approved post; the last post user otherwise' do
        user = create(:user)
        topic = create(:topic, user: user, with_posts: 1)
        post = topic.last_post
        expect(user.thredded_user_detail).to be_pending_moderation
        expect(topic.last_user).to eq user
        Thredded::ModeratePost.run!(post: topic.last_post, moderation_state: :approved, moderator: user)
        expect(user.reload.thredded_user_detail).to be_approved
        expect(topic.reload.last_user).to eq user
        expect(topic.last_post_at).to eq post.created_at
        another_user = create(:user)
        another_user_post = travel_to(1.hour.from_now) { create(:post, postable: topic, user: another_user) }
        expect(topic.reload.last_post_at).to eq post.created_at
        Thredded::ModeratePost.run!(post: another_user_post, moderation_state: :approved, moderator: user)
        expect(topic.reload.last_user).to eq another_user
        expect(topic.last_post_at).to eq another_user_post.created_at
      end
    end
  end

  describe Topic do
    before do
      @user = create(:user)
      @messageboard = create(:messageboard)
      @topic = create(:topic, messageboard: @messageboard)
    end

    it 'is associated with a messageboard' do
      topic = build(:topic, messageboard: nil)
      expect(topic).not_to be_valid
    end

    it 'handles category ids' do
      cat_1 = create(:category, messageboard: @messageboard)
      cat_2 = create(:category, :beer, messageboard: @messageboard)
      topic = create(:topic, category_ids: ['', cat_1.id, cat_2.id])
      expect(topic.valid?).to eq true
    end

    context 'when a new post is added' do
      it 'changes updated_at' do
        expect { travel_to(1.day.from_now) { create(:post, postable: @topic) } }
          .to change { @topic.reload.updated_at }
      end

      it 'changes last_post_at' do
        expect { travel_to(1.day.from_now) { create(:post, postable: @topic) } }
          .to change { @topic.reload.last_post_at }
      end

      it 'updates last_topic of the messageboard' do
        expect do
          travel_to(1.day.from_now) { create(:post, postable: @topic) }
          @messageboard.reload
        end.to change(@messageboard, :last_topic_id).from(nil).to(@topic.id)
      end
    end

    context 'when a post is deleted' do
      let(:topic) { create(:topic) }
      let(:first_post) { create(:post, postable: topic) }
      let(:second_post) { create(:post, postable: topic) }

      before do
        travel_to(1.month.ago) { first_post }
        travel_to(1.minute.ago) { second_post }
      end

      it 'changes updated_at to just now' do
        expect { second_post.destroy }
          .to change { topic.reload.updated_at }.to be_within(10).of(Time.zone.now)
      end

      it 'changes last_read_at to first post' do
        expect { second_post.destroy }
          .to change { topic.reload.last_post_at }.to eq(first_post.created_at)
      end
    end

    context 'when an old post is edited' do
      let(:topic) { create(:topic) }

      before { travel_to(1.month.ago) { @post = create(:post, postable: topic) } }

      it 'does not change updated_at' do
        expect { @post.update(content: 'hi there') }
          .not_to change {
            @post.postable.reload
            { updated_at: @post.postable.updated_at, last_post_at: @post.postable.last_post_at }
          }
      end
    end

    context 'when its messageboard is changed' do
      let(:topic) { create(:topic, with_posts: 1) }

      it 'updates last_topic on both old and new boards' do
        messageboard = topic.messageboard
        another_messageboard = create(:messageboard)
        expect do
          topic.messageboard_id = another_messageboard.id
          topic.save!
          messageboard.reload
          another_messageboard.reload
        end.to(
          change(messageboard, :last_topic_id).from(topic.id).to(nil)
            .and(change(another_messageboard, :last_topic_id).from(nil).to(topic.id))
        )
      end
    end

    it 'can have categories' do
      topic    = build(:topic)
      category = build(:category)

      topic.categories << category
      topic.save

      expect(topic.categories.size).to eq 1
      expect(topic.categories.first).to eq category
    end

    it 'naver has nil last_post_at' do
      topic = Topic.create!(messageboard_id: create(:messageboard).id, title: 'some title', user_id: create(:user).id)
      expect(topic.reload.last_post_at).not_to be_nil
      expect(topic.last_post_at).to be_within(1).of(topic.created_at)
    end
  end

  describe Topic, '.save! with embedded posts' do
    let!(:messageboard) { create(:messageboard) }
    let!(:user) { create(:user) }

    it 'saves without errors (minimum repro of rails 8.1 issue)' do
      # sort-of workaround:
      #  * turn off the counter_cache on  `Post belongs_to :user_detail` at https://github.com/thredded/thredded/blob/ec82d3171063a63855e3a51dd7a52aab8afaf3a7/app/models/thredded/post.rb#L23
      #
      # potential fix:
      #  * maybe drop the foreign key on posts to messageboard and just
      #    use the post -> topic -> messageboard key (this should be enough anyway)
      #
      # It might be a rails bug, but there are a lot of seemingly re-entrant callbacks
      topic = messageboard.topics.build(title: 'title', user: user)
      topic.posts.build(content: 'content', user: user, messageboard: messageboard)
      expect { topic.save! }.not_to raise_error
    end
  end
end
