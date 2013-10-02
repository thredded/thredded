require 'spec_helper'

module Thredded
  describe UserTopicRead do
    it { should have_db_column(:user_id) }
    it { should have_db_column(:topic_id) }
    it { should have_db_column(:post_id) }
    it { should have_db_column(:posts_count) }
    it { should have_db_column(:page) }

    it { should have_db_index(:user_id) }
    it { should have_db_index(:topic_id) }
    it { should have_db_index(:post_id) }
    it { should have_db_index(:posts_count) }
    it { should have_db_index(:page) }
  end
end
