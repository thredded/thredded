require 'spec_helper'

module Thredded
  describe UserDetail, 'associations' do
    it { should belong_to(:user) }
  end

  describe UserDetail, 'validations' do
    it { should validate_presence_of(:user_id) }
  end

  describe UserDetail, 'counter caching' do
    it 'bumps the posts count when a new post is created' do
      user = create(:user)
      user_details = create(:user_detail, user: user)
      create(:post, user: user)

      user_details.reload.posts_count.should eq(1)
    end

    it 'bumps the topics count when a new topic is created' do
      user = create(:user)
      user_details = create(:user_detail, user: user)
      create(:topic, user: user)

      user_details.reload.topics_count.should eq(1)
    end
  end
end
