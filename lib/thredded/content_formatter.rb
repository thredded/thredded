# frozen_string_literal: true
module Thredded
  # Generates HTML from content source.
  class ContentFormatter
    # Sanitization whitelist options.
    mattr_accessor :whitelist

    self.whitelist = HTML::Pipeline::SanitizationFilter::WHITELIST.deep_merge(
      elements: HTML::Pipeline::SanitizationFilter::WHITELIST[:elements] + %w(iframe span figure figcaption),
      transformers: HTML::Pipeline::SanitizationFilter::WHITELIST[:transformers] + [
        lambda do |env|
          node = env[:node]

          a_tags = node.css('a')
          a_tags.each do |a_tag|
            a_tag['href'] ||= '#'
            if a_tag['href'].starts_with? 'http'
              a_tag['target'] = '_blank'
              a_tag['rel']    = 'nofollow noopener'
            end
          end
        end
      ],
      attributes:     {
        'a'      => %w(href rel),
        'iframe' => %w(src width height frameborder allowfullscreen sandbox seamless),
        'span'   => %w(class),
      },
      add_attributes: {
        'iframe' => {
          'seamless' => 'seamless',
          'sandbox'  => 'allow-same-origin allow-scripts allow-forms',
        }
      },
      protocols: {
        'iframe' => {
          'src' => ['https', 'http', :relative]
        }
      }
    )

    # HTML::Pipeline filters.
    mattr_accessor :pipeline_filters

    self.pipeline_filters = [
      HTML::Pipeline::VimeoFilter,
      HTML::Pipeline::YoutubeFilter,
      Thredded::HtmlPipeline::BbcodeFilter,
      Thredded::HtmlPipeline::KramdownFilter,
      Thredded::HtmlPipeline::AtMentionFilter,
      # AutolinkFilter is required because Kramdown does not autolink by default.
      # https://github.com/gettalong/kramdown/issues/306
      Thredded::HtmlPipeline::AutolinkFilter,
      HTML::Pipeline::EmojiFilter,
      HTML::Pipeline::SanitizationFilter,
    ].freeze

    # @param view_context [Object] the context of the rendering view.
    # @param pipeline_options [Hash]
    def initialize(view_context, pipeline_options = {})
      @view_context = view_context
      @pipeline_options = pipeline_options
    end

    # @param content [String]
    # @return [String] formatted and sanitized html-safe content.
    def format_content(content)
      pipeline = HTML::Pipeline.new(content_pipeline_filters, content_pipeline_options.merge(@pipeline_options))
      result = pipeline.call(content, view_context: @view_context)
      # rubocop:disable Rails/OutputSafety
      result[:output].to_s.html_safe
      # rubocop:enable Rails/OutputSafety
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
