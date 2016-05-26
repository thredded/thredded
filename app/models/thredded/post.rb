# frozen_string_literal: true
module Thredded
  class Post < ActiveRecord::Base
    include PostCommon

    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_posts
    belongs_to :messageboard,
               counter_cache: true
    belongs_to :postable,
               class_name:    'Thredded::Topic',
               inverse_of:    :posts,
               counter_cache: true
    belongs_to :user_detail,
               inverse_of:    :posts,
               primary_key:   :user_id,
               foreign_key:   :user_id,
               counter_cache: true

    validates :messageboard_id, presence: true

    after_commit :auto_follow, on: [:create, :update]
    after_commit :notify_at_users, on: [:create, :update]

    def private_topic_post?
      false
    end

    # @return [ActiveRecord::Relation<Thredded.user_class>] users from the list of user names that can read this post.
    def readers_from_user_names(user_names)
      DbTextSearch::CaseInsensitive
        .new(Thredded.user_class.thredded_messageboards_readers([messageboard]), Thredded.user_name_column)
        .in(user_names)
    end

    def auto_follow
      UserTopicFollow.create_with(reason: UserTopicFollow::REASON_POSTED).
          find_or_create_by(user_id: user.id, topic_id:postable_id)
    end

    def notify_at_users
      AtNotifierJob.perform_later(self.class.name, id)
    end
  end
end
