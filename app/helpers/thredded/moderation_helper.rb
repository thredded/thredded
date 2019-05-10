# frozen_string_literal: true

module Thredded
  module ModerationHelper
    include ::Thredded::RenderHelper

    # @param records [Array<Thredded::PostModerationRecord>]
    def render_post_moderation_records(records)
      records_with_post_contents = render_collection_to_strings_with_cache(
        partial: 'thredded/moderation/post_moderation_record_content',
        collection: records, as: :post_moderation_record, expires_in: 1.week,
        locals: {
          options: {
            users_provider: ::Thredded::UsersProviderWithCache.new
          }
        }
      )
      render partial: 'thredded/moderation/post_moderation_record',
             collection: records_with_post_contents,
             as: :record_and_post_content
    end
  end
end
