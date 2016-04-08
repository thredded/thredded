require 'spec_helper'
require 'timecop'

module Thredded
  describe Topic, 'associations' do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:user_topic_reads).dependent(:destroy) }
    it { should have_many(:categories) }
    it { should belong_to(:last_user) }
    it { should belong_to(:messageboard) }
  end

  describe Topic, 'validations' do
    before { create(:topic) }
    it { should validate_presence_of(:last_user_id) }
    it { should validate_presence_of(:messageboard_id) }
    it { should validate_uniqueness_of(:hash_id) }
  end

  describe Topic, '.find_by_slug_with_user_topic_reads!' do
    it 'finds the topic' do
      topic = create(:topic, title: 'Oh Hello')

      expect(Topic.find_by_slug_with_user_topic_reads!('oh-hello')).to eq topic
    end

    it 'raises Thredded::Errors::TopicNotFound error' do
      expect { Topic.find_by_slug_with_user_topic_reads!('rubbish') }
        .to raise_error(Thredded::Errors::TopicNotFound)
    end

    it 'eager loads user_topic_reads' do
      create(:topic, title: 'Oh Hello')
      topic = Topic.find_by_slug_with_user_topic_reads!('oh-hello')

      expect(topic.association_cache).to include :user_topic_reads
    end
  end

  describe Topic, '.search' do
    it 'with text' do
      _not_a_result = create(:topic)
      topic = create(:topic,
                     title: 'xyzzy',
                     user: create(:user, name: 'glebm'))
      expect(Topic.search('xyzzy').to_a).to eq([topic])
    end

    it 'with "by:"' do
      _not_a_result = create(:topic)
      topic = create(:topic,
                     title: 'A result',
                     user: create(:user, name: 'glebm'),
                     with_posts: 1)
      expect(Topic.search('by:glebm').to_a).to eq([topic])
    end

    it 'with "in:"' do
      messageboard = create(:messageboard)
      _not_a_result = create(:topic, messageboard: messageboard)
      topic = create(:topic,
                     title: 'A result',
                     categories: [create(:category, name: 'anime', messageboard: messageboard)],
                     messageboard: messageboard)
      expect(Topic.search('in:anime').to_a).to eq([topic])
    end

    it 'with "by:" and text' do
      user = create(:user, name: 'glebm')
      _not_a_result = create(:topic)
      _not_a_result = create(:topic, user: user, with_posts: 1)
      topic = create(:topic,
                     title: 'xyzzy',
                     user: user,
                     with_posts: 1)
      expect(Topic.search('xyzzy by:glebm').to_a).to eq([topic])
    end

    it 'with "in:" and text' do
      messageboard = create(:messageboard)
      category = create(:category, name: 'anime', messageboard: messageboard)
      _not_a_result = create(:topic, messageboard: messageboard)
      _not_a_result = create(:topic, categories: [category], messageboard: messageboard)
      topic = create(:topic,
                     title: 'xyzzy',
                     categories: [category],
                     messageboard: messageboard)
      expect(Topic.search('xyzzy in:anime').to_a).to eq([topic])
    end

    it 'with "by:" and "in:" and text' do
      messageboard = create(:messageboard)
      category = create(:category, name: 'anime', messageboard: messageboard)
      user = create(:user, name: 'glebm')
      _not_a_result = create(:topic, messageboard: messageboard)
      _not_a_result = create(:topic, categories: [category], user: user, messageboard: messageboard, with_posts: 1)
      _not_a_result = create(:topic, title: 'xyzzy', user: create(:user), messageboard: messageboard, with_posts: 1)
      _not_a_result = create(:topic, title: 'xyzzy', categories: [category], messageboard: messageboard, with_posts: 1)
      topic = create(:topic,
                     title: 'xyzzy',
                     categories: [category],
                     user: user,
                     messageboard: messageboard,
                     with_posts: 1)
      expect(Topic.search('xyzzy in:anime by:glebm').to_a).to eq([topic])
    end
  end

  describe Topic, '.decorate' do
    it 'decorates topics returned from AR' do
      create_list(:topic, 3)

      expect(Topic.all.decorate.first).to be_a(Thredded::TopicDecorator)
    end
  end

  describe Topic, '#decorate' do
    it 'decorates a topic' do
      topic = create(:topic)

      expect(topic.decorate).to be_a(Thredded::TopicDecorator)
    end
  end

  describe Topic, '#last_user' do
    it 'provides anon user object when user not avail' do
      topic = build_stubbed(:topic, last_user_id: 1000)

      expect(topic.last_user).to be_instance_of NullUser
      expect(topic.last_user.to_s).to eq 'Anonymous User'
    end

    it 'returns the last user to post to this thread' do
      user = build_stubbed(:user)
      topic = build_stubbed(:topic, last_user: user)

      expect(topic.last_user).to eq(user)
    end
  end

  describe Topic do
    before(:each) do
      @user = create(:user)
      @messageboard = create(:messageboard)
      @topic  = create(:topic, messageboard: @messageboard)
    end

    it 'is associated with a messageboard' do
      topic = build(:topic, messageboard: nil)
      expect(topic).not_to be_valid
    end

    it 'handles category ids' do
      cat1 = create(:category, messageboard: @messageboard)
      cat2 = create(:category, :beer, messageboard: @messageboard)
      topic = create(:topic, category_ids: ['', cat1.id, cat2.id])
      expect(topic.valid?).to eq true
    end

    it 'changes updated_at when a new post is added' do
      old = @topic.updated_at
      create(:post, postable: @topic)

      expect(@topic.reload.updated_at).not_to eq old
    end

    it 'does not change updated_at when an old post is edited' do
      Timecop.freeze(1.month.ago) { @post = create(:post) }
      old_time = @post.postable.updated_at
      @post.update_attributes(content: 'hi there')

      expect(@post.postable.reload.updated_at.to_s).to eq old_time.to_s
    end
  end
end
