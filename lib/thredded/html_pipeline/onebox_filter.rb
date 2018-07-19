# frozen_string_literal: true

require 'onebox'

module Thredded
  module HtmlPipeline
    class OneboxFilter < ::HTML::Pipeline::Filter
      include ::Thredded::HtmlPipeline::Utils

      SANITIZE_CONFIG = Sanitize::Config.merge(
        Sanitize::Config::ONEBOX,
        attributes: {
          'a' => Sanitize::Config::ONEBOX[:attributes]['a'] + %w[target],
        },
        add_attributes: {
          'iframe' => {
            'seamless' => 'seamless',
            'sandbox' => 'allow-same-origin allow-scripts allow-forms allow-popups allow-popups-to-escape-sandbox' \
                         ' allow-presentation',
          }
        },
        transformers: (Sanitize::Config::ONEBOX[:transformers] || []) + [
          ->(env) {
            next unless env[:node_name] == 'a'
            a_tag = env[:node]
            a_tag['href'] ||= '#'
            if a_tag['href'] =~ %r{^(?:[a-z]+:)?//}
              a_tag['target'] = '_blank'
              a_tag['rel']    = 'nofollow noopener'
            else
              a_tag.remove_attribute('target')
            end
          }
        ]
      )

      class << self
        # In development and test, caching is usually disabled.
        # Regardless, always store the onebox in a file cache to enable offline development,
        # persistence between test runs, and to improve performance.
        attr_accessor :onebox_views_cache
        attr_accessor :onebox_data_cache
      end

      if Rails.env.development? || Rails.env.test?
        self.onebox_views_cache = ActiveSupport::Cache::FileStore.new('tmp/cache/onebox-views')
        self.onebox_data_cache = ActiveSupport::Cache::FileStore.new('tmp/cache/onebox-data')
      end

      def call
        doc.css('a').each do |element|
          url = element['href'].to_s
          next unless url.present? && url == element.content && on_its_own_line?(element)
          onebox_html = render_onebox_with_cache(url)
          next if onebox_html.empty?
          extract_block_from_paragraph! element
          element.swap onebox_html
        end
        doc
      end

      private

      def render_onebox_with_cache(url)
        onebox_views_cache.fetch("onebox-views:#{url}#{':p' if context[:onebox_placeholders]}",
                                 expires_in: context[:onebox_views_cache_expires_in] || 1.week) do
          render_onebox(url)
        end
      end

      def render_onebox(url)
        preview = Onebox.preview(url, onebox_options(url))
        if context[:onebox_placeholders]
          %(<p><a href="#{ERB::Util.html_escape(url)}" target="_blank" rel="nofollow noopener">) \
          "#{preview.placeholder_html}</a></p>"
        else
          preview.to_s.strip
        end
      rescue StandardError => e
        Rails.logger.error("Onebox error for #{url}: #{e}")
        <<~HTML
          <p><a href="#{ERB::Util.html_escape(url)}" target="_blank" rel="nofollow noopener">#{ERB::Util.html_escape(url)}</p>
        HTML
      end

      def onebox_options(_url)
        { cache: context[:onebox_data_cache] || self.class.onebox_data_cache || Rails.cache,
          sanitize_config: SANITIZE_CONFIG }
      end

      def onebox_views_cache
        context[:onebox_views_cache] || self.class.onebox_views_cache || Rails.cache
      end

      def on_its_own_line?(element)
        siblings = element.parent.children
        element_index = siblings.index(element)
        all_blank_until_br?(siblings[0...element_index].reverse) &&
          all_blank_until_br?(siblings[element_index + 1..-1])
      end

      def all_blank_until_br?(nodes)
        nodes.take_while { |node| !node_name?(node, 'br') }
          .all? { |node| node.text? && node.blank? }
      end
    end
  end
end
