# frozen_string_literal: true

require 'action_view/renderer/abstract_renderer'

module Thredded
  class CollectionToStringsWithCacheRenderer < ActionView::AbstractRenderer
    class << self
      # The default number of threads to use for rendering.
      attr_accessor :render_threads
    end

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
      instrument(:collection, identifier: template.identifier, count: collection.size) do |instrumentation_payload|
        return [] if collection.blank?

        # Result is a hash with the key represents the
        # key used for cache lookup and the value is the item
        # on which the partial is being rendered
        keyed_collection, ordered_keys = collection_by_cache_keys(collection, view_context, template)

        cache = collection_cache
        cached_partials = cache.read_multi(*keyed_collection.keys)
        instrumentation_payload[:cache_hits] = cached_partials.size if instrumentation_payload

        collection_to_render = keyed_collection.reject { |key, _| cached_partials.key?(key) }.values
        rendered_partials = render_partials(
          view_context,
          collection: collection_to_render, render_threads: render_threads,
          partial: partial, locals: locals, **opts
        ).each

        ordered_keys.map do |cache_key|
          [keyed_collection[cache_key], cached_partials[cache_key] || rendered_partials.next.tap do |rendered|
            cached_partials[cache_key] = cache.write(cache_key, rendered, expires_in: expires_in)
          end]
        end
      end
    end

    private

    def collection_by_cache_keys(collection, view, template)
      digest_path = digest_path_from_template(view, template)

      collection.each_with_object([{}, []]) do |item, (hash, ordered_keys)|
        key = expanded_cache_key(item, view, template, digest_path)
        ordered_keys << key
        hash[key] = item
      end
    end

    def expanded_cache_key(key, view, template, digest_path)
      key = combined_fragment_cache_key(
        view,
        cache_fragment_name(view, key, virtual_path: template.virtual_path, digest_path: digest_path)
      )
      key.frozen? ? key.dup : key # #read_multi & #write may require mutability, Dalli 2.6.0.
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
      collection.map { |object| render_partial(partial_renderer, view_context, opts.merge(object: object)) }
    end

    if Rails::VERSION::MAJOR >= 5
      def collection_cache
        ActionView::PartialRenderer.collection_cache
      end
    else
      def collection_cache
        Rails.application.config.action_controller.cache_store
      end
    end

    if Rails::VERSION::MAJOR > 5 || (Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR >= 2)
      def combined_fragment_cache_key(view, key)
        view.combined_fragment_cache_key(key)
      end
    elsif Rails::VERSION::MAJOR >= 5
      def combined_fragment_cache_key(view, key)
        view.fragment_cache_key(key)
      end
    else
      def combined_fragment_cache_key(view, key)
        view.controller.fragment_cache_key(key)
      end
    end

    if Rails::VERSION::MAJOR >= 6
      def cache_fragment_name(view, key, virtual_path:, digest_path:)
        view.cache_fragment_name(key, virtual_path: virtual_path, digest_path: digest_path)
      end

      def digest_path_from_template(view, template)
        view.digest_path_from_template(template)
      end

      def render_partial(partial_renderer, view_context, opts)
        partial_renderer.render(view_context, opts, nil).body
      end
    else
      def cache_fragment_name(_view, key, virtual_path:, digest_path:)
        if digest_path
          ["#{virtual_path}:#{digest_path}", key]
        else
          [virtual_path, key]
        end
      end

      def digest_path_from_template(view, template)
        ActionView::Digestor.digest(
          name: template.virtual_path,
          finder: @lookup_context,
          dependencies: view.view_cache_dependencies
        ).presence
      end

      def render_partial(partial_renderer, view_context, opts)
        partial_renderer.render(view_context, opts, nil)
      end
    end
  end
end
