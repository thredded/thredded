# frozen_string_literal: true
require 'action_view/renderer/abstract_renderer'
module Thredded
  class CollectionToStringsWithCacheRenderer < ActionView::AbstractRenderer
    # @param view_context
    # @param collection [Array<T>]
    # @param partial [String]
    # @param expires_in [ActiveSupport::Duration]
    # @return Array<[T, String]>
    def render_collection_to_strings_with_cache(# rubocop:disable Metrics/ParameterLists
      view_context, collection:, partial:, expires_in:, locals: {}, **opts
    )
      template = @lookup_context.find_template(partial, [], true, locals, {})
      collection = collection.to_a
      instrument(:collection, count: collection.size) do |instrumentation_payload|
        return [] if collection.blank?
        keyed_collection = collection.each_with_object({}) do |item, hash|
          key = ActiveSupport::Cache.expand_cache_key(
            view_context.cache_fragment_name(item, virtual_path: template.virtual_path), :views
          )
          # #read_multi & #write may require key mutability, Dalli 2.6.0.
          hash[key.frozen? ? key.dup : key] = item
        end
        cache = collection_cache
        cached_partials = cache.read_multi(*keyed_collection.keys)
        instrumentation_payload[:cache_hits] = cached_partials.size if instrumentation_payload

        collection_to_render = keyed_collection.reject { |key, _| cached_partials.key?(key) }.values
        rendered_partials = render_partials(
          view_context, collection: collection_to_render, partial: partial, locals: locals, **opts
        ).each

        keyed_collection.map do |cache_key, item|
          [item, cached_partials[cache_key] || rendered_partials.next.tap do |rendered|
            cache.write(cache_key, rendered, expires_in: expires_in)
          end]
        end
      end
    end

    private

    def collection_cache
      if ActionView::PartialRenderer.respond_to?(:collection_cache)
        # Rails 5.0+
        ActionView::PartialRenderer.collection_cache
      else
        # Rails 4.2.x
        Rails.application.config.action_controller.cache_store
      end
    end

    # @return [Array<String>]
    def render_partials(view_context, collection:, **opts)
      return [] if collection.empty?
      partial_renderer = ActionView::PartialRenderer.new(@lookup_context)
      collection.map do |item|
        partial_renderer.render(view_context, opts.merge(object: item), nil)
      end
    end
  end
end
