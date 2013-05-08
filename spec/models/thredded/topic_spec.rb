require 'spec_helper'
require 'timecop'

module Thredded
  describe Topic, '#last_user' do
    it 'provides anon user object when user not avail' do
      topic = build_stubbed(:topic, last_user_id: 1000)

      topic.last_user.should be_instance_of NullUser
      topic.last_user.name.should == 'Anonymous User'
    end

    it 'returns the last user to post to this thread' do
      user = build_stubbed(:user)
      topic = build_stubbed(:topic, last_user: user)

      topic.last_user.should == user
    end
  end

  describe Topic, 'associations' do
    it { should have_many(:posts) }
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


  describe Topic do
    before(:each) do
      @user = create(:user)
      @messageboard = create(:messageboard)
      @topic  = create(:topic, messageboard: @messageboard)
    end

    it 'is associated with a messageboard' do
      topic = build(:topic, messageboard: nil)
      topic.should_not be_valid
    end

    it 'is public by default' do
      topic = Topic.new
      topic.public?.should be_true
    end

    it 'handles category ids' do
      cat1 = create(:category, messageboard: @messageboard)
      cat2 = create(:category, :beer, messageboard: @messageboard)
      topic = create(:topic, category_ids: ['', cat1.id, cat2.id])
      topic.valid?.should be_true
    end

    it 'changes updated_at when a new post is added' do
      old = @topic.updated_at
      create(:post, topic: @topic)

      @topic.reload.updated_at.should_not eq old
    end

    it 'does not change updated_at when an old post is edited' do
      Timecop.freeze(1.month.ago) do
        @post = create(:post)
      end

      old_time = @post.topic.updated_at
      @post.update_attribute(:content, 'hi there')
      @post.topic.reload.updated_at.to_s.should eq old_time.to_s
    end
  end
end
