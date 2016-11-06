# frozen_string_literal: true
module Thredded
  module HtmlPipeline
    # HTML Filter for auto_linking urls in HTML.
    #
    # AutolinkFilter is required because Kramdown does not autolink by default.
    # https://github.com/gettalong/kramdown/issues/306
    class AutolinkFilter < HTML::Pipeline::Filter
      def call
        Rinku.auto_link(html, :all)
      end
    end
  end
end
