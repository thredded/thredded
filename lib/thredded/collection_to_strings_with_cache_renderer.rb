# frozen_string_literal: true

require 'action_view/renderer/abstract_renderer'

module Thredded
  class CollectionToStringsWithCacheRenderer < ActionView::AbstractRenderer
    # The default number of threads to use for rendering.
    mattr_accessor :render_threads
    self.render_threads = 50

    # @param view_context
    # @param [Array<T>] collection
    # @param [String] partial
    # @param [ActiveSupport::Duration] expires_in
    # @param [Integer] render_threads the number of threads to use for rendering. This is useful even on MRI ruby
    #   for IO-bound operations.
    # @param [Hash] locals
    # @return Array<[T, String]>
    def render_collection_to_strings_with_cache( # rubocop:disable Metrics/ParameterLists
      view_context, collection:, partial:, expires_in:, render_threads: self.class.render_threads, locals: {}, **opts
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
          view_context,
          collection: collection_to_render, render_threads: render_threads,
          partial: partial, locals: locals, **opts
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
    def render_partials(view_context, collection:, render_threads:, **opts)
      return [] if collection.empty?
      num_threads = [render_threads, collection.size].min
      if num_threads == 1
        render_partials_serial(view_context, collection, opts)
      else
        collection.each_slice(collection.size / num_threads).map do |slice|
          Thread.start { render_partials_serial(view_context.dup, slice, opts) }
        end.flat_map(&:value)
      end
    end

    # @param [Array<Object>] collection
    # @param [Hash] opts
    # @param view_context
    # @return [Array<String>]
    def render_partials_serial(view_context, collection, opts)
      partial_renderer = ActionView::PartialRenderer.new(@lookup_context)
      collection.map { |object| partial_renderer.render(view_context, opts.merge(object: object), nil) }
    end
  end
end
