# frozen_string_literal: true

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
      Thredded::HtmlPipeline::AtMentionFilter.new(
        html,
        view_context: view_context,
        users_provider: ::Thredded::UsersProvider,
        users_provider_scope: @post.readers
      ).mentioned_users
    end
  end
end
