# frozen_string_literal: true
require 'thredded/at_users'

module HTML
  class Pipeline
    class AtMentionFilter < Filter
      # @param context [Hash]
      # @options context :users_provider [#call(usernames)] given usernames, returns a list of users.
      def initialize(text, context = nil, result = nil)
        super text, context, result
        @text = text.to_s.delete("\r")
        @users_provider = context[:users_provider]
        @view_context = context[:view_context]
      end

      def call
        return html unless @users_provider
        html = Thredded::AtUsers.render(@text, @users_provider, @view_context)
        html.rstrip!
        html
      end
    end
  end
end
