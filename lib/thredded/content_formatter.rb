# frozen_string_literal: true

module Thredded
  # Generates HTML from content source.
  class ContentFormatter
    # Sanitization whitelist options.
    mattr_accessor :whitelist

    self.whitelist = HTML::Pipeline::SanitizationFilter::WHITELIST.deep_merge(
      elements: HTML::Pipeline::SanitizationFilter::WHITELIST[:elements] + %w[abbr iframe span figure figcaption],
      transformers: HTML::Pipeline::SanitizationFilter::WHITELIST[:transformers] + [
        lambda do |env|
          next unless env[:node_name] == 'a'
          a_tag = env[:node]
          a_tag['href'] ||= '#'
          if a_tag['href'] =~ %r{^(?:[a-z]+:)?//}
            a_tag['target'] = '_blank'
            a_tag['rel']    = 'nofollow noopener'
          end
        end
      ],
      attributes: {
        'a'      => %w[href rel],
        'abbr'   => %w[title],
        'span'   => %w[class],
        'div'    => %w[class],
        :all     => HTML::Pipeline::SanitizationFilter::WHITELIST[:attributes][:all] +
          %w[aria-label aria-labelledby aria-hidden],
      }
    )

    # Filters that run before processing the markup.
    # input: markup, output: markup.
    mattr_accessor :before_markup_filters
    self.before_markup_filters = [
    ]

    # Markup filters, such as BBCode, Markdown, Autolink, etc.
    # input: markup, output: html.
    mattr_accessor :markup_filters
    self.markup_filters = [
      Thredded::HtmlPipeline::KramdownFilter,
    ]

    # Filters that run after processing the markup.
    # input: html, output: html.
    mattr_accessor :after_markup_filters
    self.after_markup_filters = [
      # AutolinkFilter is required because Kramdown does not autolink by default.
      # https://github.com/gettalong/kramdown/issues/306
      Thredded::HtmlPipeline::AutolinkFilter,
      HTML::Pipeline::EmojiFilter,
      Thredded::HtmlPipeline::AtMentionFilter,
    ]

    # Filters that sanitize the resulting HTML.
    # input: html, output: sanitized html.
    mattr_accessor :sanitization_filters
    self.sanitization_filters = [
      HTML::Pipeline::SanitizationFilter,
    ]

    # Filters that run after sanitization
    # input: sanitized html, output: html
    mattr_accessor :after_sanitization_filters
    self.after_sanitization_filters = [
      Thredded::HtmlPipeline::OneboxFilter,
      Thredded::HtmlPipeline::WrapIframesFilter,
    ]

    # All the HTML::Pipeline filters, read-only.
    def self.pipeline_filters
      filters = [
        *before_markup_filters,
        *markup_filters,
        *after_markup_filters,
        *sanitization_filters,
        *after_sanitization_filters
      ]
      # Changing the result in-place has no effect on the ContentFormatter output,
      # and is most likely the result of a programmer error.
      # Freeze the array so that in-place changes raise an error.
      filters.freeze
    end

    # @param view_context [Object] the context of the rendering view.
    # @param pipeline_options [Hash]
    def initialize(view_context, pipeline_options = {})
      @view_context = view_context
      @pipeline_options = pipeline_options
    end

    # @param content [String]
    # @return [String] formatted and sanitized html-safe content.
    def format_content(content)
      pipeline = HTML::Pipeline.new(content_pipeline_filters, content_pipeline_options.deep_merge(@pipeline_options))
      result = pipeline.call(content, view_context: @view_context)
      # rubocop:disable Rails/OutputSafety
      result[:output].to_s.html_safe
      # rubocop:enable Rails/OutputSafety
    end

    # @param content [String]
    # @return [String] a quote containing the formatted content
    def self.quote_content(content)
      result = String.new(content)
      result.gsub!(/^(?!$)/, '> ')
      result.gsub!(/^$/, '>')
      result << "\n" unless result.end_with?("\n")
      result << "\n"
      result
    end

    protected

    # @return [Array<HTML::Pipeline::Filter]>]
    def content_pipeline_filters
      ContentFormatter.pipeline_filters
    end

    # @return [Hash] options for HTML::Pipeline.new
    def content_pipeline_options
      {
        asset_root: Rails.application.config.action_controller.asset_host || '',
        whitelist: ContentFormatter.whitelist
      }
    end
  end
end
