module Thredded
  class Post < ActiveRecord::Base
    include PostCommon

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
    before_validation :set_filter_from_messageboard

    def private_topic_post?
      false
    end

    # @return [ActiveRecord::Relation<Thredded.user_class>] users from the list of user names that can read this post.
    def readers_from_user_names(user_names)
      DbTextSearch::CaseInsensitiveEq
        .new(Thredded.user_class.thredded_messageboards_readers([messageboard]), Thredded.user_name_column)
        .find(user_names)
    end

    private

    def set_filter_from_messageboard
      self.filter = messageboard.filter if messageboard
    end
  end
end
