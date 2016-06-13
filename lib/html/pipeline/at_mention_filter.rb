# frozen_string_literal: true
module HTML
  class Pipeline
    class AtMentionFilter < Filter
      DEFAULT_IGNORED_ANCESTOR_TAGS = %w(pre code tt a style).freeze

      # @param context [Hash]
      # @options context :users_provider [#call(usernames)] given usernames, returns a list of users.
      def initialize(doc, context = nil, result = nil)
        super doc, context, result
        @users_provider = context[:users_provider]
        @view_context = context[:view_context]
      end

      def call
        return doc unless @users_provider
        process_text_nodes! do |node|
          content = node.to_html
          next unless content.include?('@')
          highlight! content
          node.replace content
        end
        doc
      end

      # @return [Array<Thredded.user_class>] users that were @-mentioned
      def mentioned_users
        return [] unless @users_provider
        names = []
        process_text_nodes! { |node| names.concat mentioned_names(node.to_html) }
        names.uniq!
        @users_provider.call(names)
      end

      private

      MATCH_NAME_RE = /(?:^|[\s>])@([\w]+|"[\w ]+")(?=\W|$)/

      def mentioned_names(text_node_html)
        text_node_html.scan(MATCH_NAME_RE).map(&:first).map { |m| m.start_with?('"') ? m[1..-2] : m }
      end

      def highlight!(text_node_html)
        names = mentioned_names(text_node_html)
        return unless names.present?
        @users_provider.call(names).each do |user|
          name = user.to_s
          maybe_quoted_name = name.include?(' ') ? %("#{name}") : name
          url = Thredded.user_path(@view_context, user)
          text_node_html.gsub!(
            /(^|[\s>])(@#{Regexp.escape maybe_quoted_name})([^a-z\d]|$)/i,
            %(\\1<a href="#{ERB::Util.html_escape url}">@#{ERB::Util.html_escape maybe_quoted_name}</a>\\3)
          )
        end
      end

      # Yields text nodes that should be processed.
      def process_text_nodes!
        doc.search('.//text()').each do |node|
          next if has_ancestor?(node, ignored_ancestor_tags)
          yield node
        end
      end

      # Return ancestor tags to stop the at-mention highlighting.
      #
      # @return [Array<String>] Ancestor tags.
      def ignored_ancestor_tags
        if @context[:ignored_ancestor_tags]
          DEFAULT_IGNORED_ANCESTOR_TAGS | @context[:ignored_ancestor_tags]
        else
          DEFAULT_IGNORED_ANCESTOR_TAGS
        end
      end
    end
  end
end
