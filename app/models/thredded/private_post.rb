# frozen_string_literal: true
module Thredded
  class PrivatePost < ActiveRecord::Base
    include PostCommon

    belongs_to :user,
               class_name: Thredded.user_class,
               inverse_of: :thredded_private_posts
    belongs_to :postable,
               class_name:    'Thredded::PrivateTopic',
               inverse_of:    :posts,
               counter_cache: :posts_count
    belongs_to :user_detail,
               inverse_of:  :private_posts,
               primary_key: :user_id,
               foreign_key: :user_id

    after_commit :notify_users, on: [:create]

    # @param [Integer] per_page
    def page(per_page: self.class.default_per_page)
      1 + postable.posts.where(postable.posts.arel_table[:id].lt(id)).count / per_page
    end

    def private_topic_post?
      true
    end

    def user_detail
      super || build_user_detail
    end

    # @return [ActiveRecord::Relation<Thredded.user_class>] users from the list of user names that can read this post.
    def readers_from_user_names(user_names)
      DbTextSearch::CaseInsensitive
        .new(postable.users, Thredded.user_name_column)
        .in(user_names)
    end

    def notify_users
      Thredded::NotifyPrivateTopicUsersJob.perform_later(id)
    end
  end
end
