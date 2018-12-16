# frozen_string_literal: true

module Thredded
  module UsersProvider
    module_function

    def call(user_names, scope)
      DbTextSearch::CaseInsensitive
        .new(scope, Thredded.user_name_column)
        .in(user_names)
    end
  end

  class UsersProviderWithCache
    def initialize
      @mutex = Mutex.new
      @cache = {}
    end

    def call(names, scope)
      # This is not the same as the database lowercasing but it's OK.
      # The worst that can happen is some cache misses.
      names_with_lowercase = names.zip(names.map(&:downcase))
      cached = uncached = nil
      result = @mutex.synchronize do
        scope_cache = (@cache[scope.to_sql] ||= {})
        cached, uncached = names_with_lowercase.partition { |(_, lowercase)| scope_cache.key?(lowercase) }
        fetched = UsersProvider.call(uncached.map(&:first), scope)
        fetched.each do |user|
          scope_cache[user.send(Thredded.user_name_column).downcase] = user
        end
        cached.map { |(_, lowercase)| scope_cache[lowercase] }.concat(fetched)
      end
      result.uniq!
      result.compact!
      Rails.logger.info(
        "  [Thredded::UsersProviderWithCache] #{names.size} user names => #{result.size} users "\
          "(#{cached.size} cached, #{uncached.size} uncached)"
      )
      result
    end
  end
end
