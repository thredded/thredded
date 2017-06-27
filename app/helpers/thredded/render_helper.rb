# frozen_string_literal: true

module Thredded
  module RenderHelper
    # @param collection [Array<T>]
    # @param partial [String]
    # @param expires_in [ActiveSupport::Duration]
    # @return Array<[T, String]>
    def render_collection_to_strings_with_cache(collection:, partial:, expires_in:, **opts)
      Thredded::CollectionToStringsWithCacheRenderer.new(lookup_context).render_collection_to_strings_with_cache(
        self, collection: collection, partial: partial, expires_in: expires_in, **opts
      )
    end
  end
end
