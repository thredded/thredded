# frozen_string_literal: true
require 'thredded/html_pipeline/at_mention_filter'
module Thredded
  class AtNotificationExtractor
    def initialize(post)
      @post = post
    end

    # @return [Array<Thredded.user_class>]
    def run
      view_context = Thredded::ApplicationController.new.view_context
      # Do not highlight @-mentions at first, because:
      # * When parsing, @-mentions within <a> tags will not be considered.
      # * We can't always generate the user URL here because request.host is not available.
      html = @post.filtered_content(view_context, users_provider: nil)
      HTML::Pipeline::AtMentionFilter.new(
        html,
        view_context: view_context,
        users_provider: -> (user_names) { @post.readers_from_user_names(user_names).to_a }
      ).mentioned_users
    end
  end
end
