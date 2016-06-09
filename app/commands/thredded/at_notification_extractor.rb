# frozen_string_literal: true
module Thredded
  class AtNotificationExtractor
    # Matches the names in @joe, @"Joe 1", but not email@host.com.
    # The matched name is captured and may contain the surrounding quotes.
    MATCH_NAME_RE = /(?:^|[\s>])@([\w]+|"[\w ]+")(?=\W|$)/

    def initialize(content)
      @content = content
    end

    def run
      @content.scan(MATCH_NAME_RE).map(&:first).map { |m| m.start_with?('"') ? m[1..-2] : m }.uniq
    end
  end
end
