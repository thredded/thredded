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

    after_commit :auto_follow_and_notify, on: [:create, :update]

    def private_topic_post?
      false
    end

    # @return [ActiveRecord::Relation<Thredded.user_class>] users from the list of user names that can read this post.
    def readers_from_user_names(user_names)
      DbTextSearch::CaseInsensitive
        .new(Thredded.user_class.thredded_messageboards_readers([messageboard]), Thredded.user_name_column)
        .in(user_names)
    end

    def auto_follow_and_notify
      # need to do this in-process so that it appears to them immediately
      UserTopicFollow.create_unique(user.id, postable_id, UserTopicFollow::REASON_POSTED)
      # everything else can happen later
      AutoFollowAndNotifyJob.perform_later(id)
    end
  end
end
