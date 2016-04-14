# frozen_string_literal: true
require 'set'
module Thredded
  # Excludes pagination routes in addition to the given list of reserved words.
  class FriendlyIdReservedWordsAndPagination
    PAGINATION_PATTERN = /\Apage-\d+\z/i

    def initialize(words = [])
      @words = Set.new(words)
    end

    def include?(slug)
      @words.include?(slug) || slug =~ PAGINATION_PATTERN
    end
  end
end
