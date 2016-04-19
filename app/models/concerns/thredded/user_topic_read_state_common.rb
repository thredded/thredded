# frozen_string_literal: true
module Thredded
  module UserTopicReadStateCommon
    extend ActiveSupport::Concern
    included do
      extend ClassMethods
      validates :user_id, uniqueness: { scope: :postable_id }
    end

    # @return [Boolean]
    def read?
      postable.updated_at <= read_at
    end

    module ClassMethods
      # @param user_id [Fixnum]
      # @param topic_id [Fixnum]
      # @param post [Thredded::PostCommon]
      # @param post_page [Fixnum]
      def touch!(user_id, topic_id, post, post_page)
        # TODO: Switch to upsert once Travis supports PostgreSQL 9.5.
        # Travis issue: https://github.com/travis-ci/travis-ci/issues/4264
        # Upsert gem: https://github.com/seamusabshere/upsert
        state = where(user_id: user_id, postable_id: topic_id).first_or_initialize
        fail ArgumentError, "expected post_page >= 1, given #{post_page.inspect}" if post_page < 1
        return unless !state.read_at? || state.read_at < post.updated_at
        state.update!(read_at: post.updated_at, page: post_page)
      end
    end
  end
end
