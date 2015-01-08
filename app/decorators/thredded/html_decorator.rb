module Thredded
  module HtmlDecorator
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::DateHelper
    include Rails::Timeago::Helper
    include Rails.application.routes.url_helpers
    include Thredded::UrlHelper

    def timeago_tag(time, html_options = {})
      super(time, timeago_tag_defaults.deep_merge(html_options))
    end

    def timeago_tag_defaults
      {limit:   nil,
       default: I18n.t('thredded.timeago.nil_text')}
    end
  end
end
